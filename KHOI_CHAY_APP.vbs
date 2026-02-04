Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' Get script directory
ScriptPath = WScript.ScriptFullName
CurrentPath = FSO.GetParentFolderName(ScriptPath)
ElectronPath = CurrentPath & "\electron"

' Show notification first
MsgBox "EnviroAnalyzer Pro is starting!" & vbCrLf & vbCrLf & _
       "The application will open in a few seconds.", _
       vbInformation, "EnviroAnalyzer Pro v3.1"

' Change to electron directory and run npm start (completely hidden)
WshShell.CurrentDirectory = ElectronPath
WshShell.Run "npm.cmd start", 0, False

WScript.Quit
