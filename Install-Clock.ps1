#requires -Version 5.1
#requires -RunAsAdministrator

<#
.SYNOPSIS
    Установщик для виджета часов на рабочем столе Windows.
.DESCRIPTION
    Этот скрипт устанавливает виджет часов, который использует иконки папок на рабочем столе для отображения текущего времени.
.NOTES
    Версия 2.0: Исправлена ошибка с поиском desktop.ini сразу после создания.
#>

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

try {
    Write-Log "Начало установки виджета часов..."

    # --- 1. Определение путей и переменных ---
    $scriptRoot = $PSScriptRoot
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    
    # Папка для хранения всех ресурсов
    $assetDir = Join-Path $env:LOCALAPPDATA "DesktopClock"
    
    # Имена папок для отображения времени
    $clockFolders = @("HH", "H", "o", "MM", "M")
    
    # Исходные файлы
    $sourceVbs = Join-Path $scriptRoot "time.vbs"
    $sourceXml = Join-Path $scriptRoot "Update Folder Icons.xml"
    $iconFiles = Get-ChildItem -Path $scriptRoot -Filter "*.ico"

    # Проверка наличия всех необходимых файлов
    if (-not (Test-Path $sourceVbs) -or -not (Test-Path $sourceXml) -or $iconFiles.Count -eq 0) {
        throw "Ошибка: Не все файлы (time.vbs, Update Folder Icons.xml, *.ico) найдены в папке со скриптом."
    }

    # --- 2. Создание папок и копирование файлов ---
    Write-Log "Создание папки для ресурсов: $assetDir"
    if (-not (Test-Path $assetDir)) {
        New-Item -Path $assetDir -ItemType Directory | Out-Null
    }

    Write-Log "Копирование иконок и VBS-скрипта..."
    Copy-Item -Path $iconFiles.FullName -Destination $assetDir -Force
    Copy-Item -Path $sourceVbs -Destination $assetDir -Force
    $vbsPathInAssets = Join-Path $assetDir "time.vbs"

    # --- 3. Настройка файлов ---
    Write-Log "Настройка VBS-скрипта..."
    $vbsContent = Get-Content -Path $vbsPathInAssets -Raw
    $vbsContent = $vbsContent -replace 'icon_path = ".*"', "icon_path = ""$assetDir"""
    Set-Content -Path $vbsPathInAssets -Value $vbsContent -Force -Encoding Default

    Write-Log "Настройка XML-файла для Планировщика задач..."
    $xmlContent = Get-Content -Path $sourceXml -Raw
    # Заменяем <Command>time.vbs</Command> на полный путь к скрипту
$xmlContent = $xmlContent -replace '<Command>time.vbs</Command>', "<Command>$vbsPathInAssets</Command>"
    $tempXmlPath = Join-Path $env:TEMP "TaskDefinition.xml"
    Set-Content -Path $tempXmlPath -Value $xmlContent -Encoding Unicode -Force

    # --- 4. Создание папок на рабочем столе ---
    Write-Log "Создание папок на рабочем столе..."
    foreach ($folder in $clockFolders) {
        $fullPath = Join-Path $desktopPath $folder
        if (-not (Test-Path $fullPath)) {
            New-Item -Path $fullPath -ItemType Directory | Out-Null
            Write-Log "Создана папка: $fullPath"
        }
    }
    
    # --- 5. Назначение иконки для папки "o" ---
    Write-Log "Назначение иконки для папки 'o'..."
    $oFolderPath = Join-Path $desktopPath "o"
    $oIconPath = Join-Path $assetDir "o.ico"
    $desktopIniPath = Join-Path $oFolderPath "desktop.ini"

    # Создание файла desktop.ini
    $iniContent = @"
[.ShellClassInfo]
IconResource=$oIconPath,0
"@
    
	# Создаем файл desktop.ini
    Set-Content -Path $desktopIniPath -Value $iniContent -Force

    # === ИСПРАВЛЕНИЕ ЗДЕСЬ ===
    # Используем внешнюю утилиту attrib.exe для надежной установки атрибутов.
    # Это решает проблему, когда Get-Item не находит файл или папку сразу после создания.
    & attrib.exe +H +S "$desktopIniPath"  # Установить атрибуты Скрытый и Системный для файла
    & attrib.exe +R "$oFolderPath"       # Установить атрибут Только чтение для папки 'o'
    
    # --- 6. Импорт задачи в Планировщик задач ---
    Write-Log "Импорт задачи 'Update Desktop Clock' в Планировщик..."
    schtasks.exe /Create /TN "Update Desktop Clock" /XML "$tempXmlPath" /F
    if ($LASTEXITCODE -ne 0) {
        throw "Не удалось импортировать задачу в Планировщик."
    }
    
# --- 7. Обновление рабочего стола и очистка ---
Write-Log "Обновление кэша иконок оболочки..."

# Используем -TypeDefinition, чтобы правильно разместить директивы 'using' в C# коде.
$csharpCode = @"
using System;
using System.Runtime.InteropServices;

public class ShellRefresher
{
    [DllImport("shell32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
    public static extern void SHChangeNotify(long wEventId, long uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@
Add-Type -TypeDefinition $csharpCode

# Вызываем статический метод из созданного класса.
# SHCNE_ASSOCCHANGED заставляет оболочку перечитать сопоставления и иконки.
[ShellRefresher]::SHChangeNotify(0x08000000, 0x0000, [System.IntPtr]::Zero, [System.IntPtr]::Zero)

Write-Log "Очистка временных файлов..."
Remove-Item -Path $tempXmlPath -Force

    Write-Log "Установка успешно завершена!" -Level "SUCCESS"

}
catch {
    Write-Log "Произошла критическая ошибка:" -Level "ERROR"
    Write-Log $_.Exception.Message -Level "ERROR"
    Read-Host "Нажмите Enter, чтобы выйти."
    exit 1
}