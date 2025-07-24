' --- Настройки текста ---
Dim title, message
title = "Установка Desktop Clock"
message = "Сейчас будет установлены часы на рабочем столе" & vbCrLf & vbCrLf
message = message & "Он использует 5 папок на для отображения времени с помощью иконок." & vbCrLf & vbCrLf
message = message & "Продолжить установку?"

' --- Отображение окна и обработка выбора ---
Dim userChoice
userChoice = MsgBox(message, vbOKCancel + vbQuestion, title)

' Проверяем, что нажал пользователь
If userChoice = vbOK Then
    ' Если "ОК", выходим с кодом 0 (успех, продолжаем)
    WScript.Quit(0)
Else
    ' Если "Отмена" или закрыл окно, выходим с кодом 1 (отмена)
    WScript.Quit(1)
End If