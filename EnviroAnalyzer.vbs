' EnviroAnalyzer Pro Launcher
' This VBScript launches the R Shiny application
' Can be compiled to EXE using vbs2exe or similar tools

Option Explicit

Dim objShell, objFSO, strAppPath, strRPath, strCommand
Dim intResult

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get application path
strAppPath = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Find R installation
strRPath = FindR()

If strRPath = "" Then
    MsgBox "R is not installed!" & vbCrLf & vbCrLf & _
           "Please download and install R from:" & vbCrLf & _
           "https://cran.r-project.org/bin/windows/base/", _
           vbCritical, "EnviroAnalyzer Pro"
    WScript.Quit 1
End If

' Change to app directory and run
objShell.CurrentDirectory = strAppPath

' Build command
strCommand = """" & strRPath & """ -e ""shiny::runApp('app.R', port = 3838, host = '127.0.0.1', launch.browser = TRUE)"""

' Run R with the Shiny app
objShell.Run strCommand, 1, False

' Function to find R installation
Function FindR()
    Dim arrPaths, strPath, strVersion, i
    
    FindR = ""
    
    ' Common R installation paths
    arrPaths = Array( _
        "C:\Program Files\R\R-4.5.2\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.5.1\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.5.0\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.4.2\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.4.1\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.4.0\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.3.0\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.2.0\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.1.0\bin\Rscript.exe", _
        "C:\Program Files\R\R-4.0.0\bin\Rscript.exe" _
    )
    
    For i = 0 To UBound(arrPaths)
        If objFSO.FileExists(arrPaths(i)) Then
            FindR = arrPaths(i)
            Exit Function
        End If
    Next
    
    ' Try to find from registry
    On Error Resume Next
    strPath = objShell.RegRead("HKLM\SOFTWARE\R-core\R\InstallPath")
    If Err.Number = 0 And strPath <> "" Then
        strPath = strPath & "\bin\Rscript.exe"
        If objFSO.FileExists(strPath) Then
            FindR = strPath
            Exit Function
        End If
    End If
    Err.Clear
    
    strPath = objShell.RegRead("HKLM\SOFTWARE\WOW6432Node\R-core\R\InstallPath")
    If Err.Number = 0 And strPath <> "" Then
        strPath = strPath & "\bin\Rscript.exe"
        If objFSO.FileExists(strPath) Then
            FindR = strPath
            Exit Function
        End If
    End If
    On Error GoTo 0
End Function
