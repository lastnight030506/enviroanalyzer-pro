; ============================================================================
; ENVIROANALYZER PRO - INNO SETUP INSTALLER SCRIPT
; ============================================================================
; This creates a Windows installer for the Shiny app
; Run with: "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
; ============================================================================

#define MyAppName "EnviroAnalyzer Pro"
#define MyAppVersion "3.0.0"
#define MyAppPublisher "Environmental Engineering Team"
#define MyAppURL "https://github.com/lastnight030506/enviroanalyzer-pro"
#define MyAppExeName "run_app.bat"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE
OutputDir=installer_output
OutputBaseFilename=EnviroAnalyzer_Pro_Setup_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; App files
Source: "app.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "constants.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "functions.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "visuals.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "run.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion

; Launcher batch file (created during install)
Source: "launcher\run_app.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent shellexec
