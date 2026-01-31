; ============================================================================
; ENVIROANALYZER PRO - STANDALONE INSTALLER
; ============================================================================
; Full installer (~300 MB) - Includes R Portable + all packages
; Works out-of-the-box without any R installation
; ============================================================================

#define MyAppName "EnviroAnalyzer Pro"
#define MyAppVersion "3.0.0"
#define MyAppPublisher "Environmental Engineering Team"
#define MyAppURL "https://github.com/lastnight030506/enviroanalyzer-pro"
#define MyAppExeName "EnviroAnalyzer.bat"
#define RVersion "4.4.2"

[Setup]
AppId={{EA-STAND-A1B2-C3D4-E5F6-789012345678}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion} (Standalone)
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\build_output\standalone\LICENSE
OutputDir=..\build_output\standalone
OutputBaseFilename=EnviroAnalyzer_Standalone_Setup
SetupIconFile=..\assets\app.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\app.ico
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=EnviroAnalyzer Pro - Standalone Installer (includes R)
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
; Larger disk space required
DiskSpanning=no
DiskSliceSize=max

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%n✅ This is the Standalone version.%n%nIt includes R Portable and all required packages. No additional software installation is needed.%n%nThe application will work immediately after installation.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Application files
Source: "..\build_output\standalone\app.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\standalone\constants.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\standalone\functions.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\standalone\visuals.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\standalone\run.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\standalone\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\standalone\EnviroAnalyzer.bat"; DestDir: "{app}"; Flags: ignoreversion

; R Portable (entire R installation with packages)
Source: "..\build_output\standalone\R-Portable\*"; DestDir: "{app}\R-Portable"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent shellexec

[UninstallDelete]
; Clean up any generated files
Type: filesandordirs; Name: "{app}\R-Portable"
Type: filesandordirs; Name: "{app}"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Post-installation tasks can be added here
    // For example: registering file associations, etc.
  end;
end;
