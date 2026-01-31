; EnviroAnalyzer Pro - Inno Setup Script
; This script creates a Windows installer

#define MyAppName "EnviroAnalyzer Pro"
#define MyAppVersion "3.0.0"
#define MyAppPublisher "EnviroAnalyzer Team"
#define MyAppURL "https://github.com/yourusername/enviroanalyzer-pro"
#define MyAppExeName "EnviroAnalyzer.exe"

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
OutputDir=installer
OutputBaseFilename=EnviroAnalyzer_Pro_Setup
SetupIconFile=icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Application files
Source: "app.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "constants.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "functions.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "visuals.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "install_packages.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "run_app.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "setup.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion
; Launcher executable
Source: "EnviroAnalyzer.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Run setup to install R packages after installation
Filename: "{app}\setup.bat"; Description: "Install required R packages"; Flags: postinstall skipifsilent shellexec waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Check if R is installed
function IsRInstalled(): Boolean;
var
  RPath: String;
begin
  Result := RegQueryStringValue(HKLM, 'SOFTWARE\R-core\R', 'InstallPath', RPath) or
            RegQueryStringValue(HKLM64, 'SOFTWARE\R-core\R', 'InstallPath', RPath) or
            RegQueryStringValue(HKCU, 'SOFTWARE\R-core\R', 'InstallPath', RPath);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if not IsRInstalled() then
  begin
    if MsgBox('R is not installed on this computer.' + #13#10 + #13#10 +
              'EnviroAnalyzer Pro requires R 4.0 or later.' + #13#10 + #13#10 +
              'Would you like to download R now?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      ShellExec('open', 'https://cran.r-project.org/bin/windows/base/', '', '', SW_SHOW, ewNoWait, Result);
    end;
    Result := False;
  end;
end;
