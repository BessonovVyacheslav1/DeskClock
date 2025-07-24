On Error Resume Next

Set objShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim desktopPath
desktopPath = objShell.ExpandEnvironmentStrings("%USERPROFILE%\Desktop")

Dim folderHH, folderH, folderMM, folderM
folderHH = desktopPath & "\HH"
folderH  = desktopPath & "\H"
folderMM = desktopPath & "\MM"
folderM  = desktopPath & "\M"

Dim icon_path
icon_path = "C:\Ico\NumbersFolder"

Dim currentHour, currentMinute
currentHour   = Right("0" & Hour(Now), 2)
currentMinute = Right("0" & Minute(Now), 2)

Dim h1, h2, m1, m2
h1 = Mid(currentHour, 1, 1)
h2 = Mid(currentHour, 2, 1)
m1 = Mid(currentMinute, 1, 1)
m2 = Mid(currentMinute, 2, 1)

Sub ChangeIcon(folderPath, iconName)
    If Not fso.FolderExists(folderPath) Then Exit Sub

    Dim desktopIniPath
    desktopIniPath = folderPath & "\desktop.ini"
    
    fso.GetFolder(folderPath).Attributes = fso.GetFolder(folderPath).Attributes And Not 1
    If fso.FileExists(desktopIniPath) Then
        fso.GetFile(desktopIniPath).Attributes = 0
        fso.DeleteFile desktopIniPath, True
    End If
    Dim desktopIniFile
    Set desktopIniFile = fso.CreateTextFile(desktopIniPath, True)
    desktopIniFile.WriteLine "[.ShellClassInfo]"
    desktopIniFile.WriteLine "IconResource=" & icon_path & "\" & iconName & ".ico,0"
    desktopIniFile.Close
    fso.GetFile(desktopIniPath).Attributes = 2 + 4
    fso.GetFolder(folderPath).Attributes = fso.GetFolder(folderPath).Attributes Or 1
End Sub

ChangeIcon folderHH, h1
ChangeIcon folderH,  h2
ChangeIcon folderMM, m1
ChangeIcon folderM,  m2
WScript.Quit