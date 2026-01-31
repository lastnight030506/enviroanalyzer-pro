; ============================================================================
; ENVIROANALYZER PRO - LIGHTWEIGHT INSTALLER
; ============================================================================
; Small installer (~2 MB) - Requires user to have R installed
; If R not found, redirects to R download page
; ============================================================================

#define MyAppName "EnviroAnalyzer Pro"
#define MyAppVersion "3.0.0"
#define MyAppPublisher "Environmental Engineering Team"
#define MyAppURL "https://github.com/lastnight030506/enviroanalyzer-pro"
#define MyAppExeName "EnviroAnalyzer.bat"

[Setup]
AppId={{EA-LIGHT-A1B2-C3D4-E5F6-789012345678}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion} (Lightweight)
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\build_output\lightweight\LICENSE
OutputDir=..\build_output\lightweight
OutputBaseFilename=EnviroAnalyzer_Lightweight_Setup
SetupIconFile=..\assets\app.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\app.ico
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=EnviroAnalyzer Pro - Lightweight Installer
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%n⚠️ IMPORTANT: This is the Lightweight version.%n%nR must be installed on your system. If R is not installed, you will be redirected to download it.%n%nFor a version that works without R, download the Standalone version.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Application files
Source: "..\build_output\lightweight\app.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\lightweight\constants.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\lightweight\functions.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\lightweight\visuals.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\lightweight\run.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\lightweight\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build_output\lightweight\EnviroAnalyzer.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent shellexec

[Code]
// Check if R is installed
function IsRInstalled(): Boolean;
var
  RVersions: array of String;
  i: Integer;
  RPath: String;
begin
  Result := False;
  SetArrayLength(RVersions, 10);
  RVersions[0] := '4.5.2';
  RVersions[1] := '4.5.1';
  RVersions[2] := '4.5.0';
  RVersions[3] := '4.4.2';
  RVersions[4] := '4.4.1';
  RVersions[5] := '4.4.0';
  RVersions[6] := '4.3.3';
  RVersions[7] := '4.3.2';
  RVersions[8] := '4.3.1';
  RVersions[9] := '4.3.0';
  
  for i := 0 to GetArrayLength(RVersions) - 1 do
  begin
    RPath := ExpandConstant('{pf}\R\R-' + RVersions[i] + '\bin\Rscript.exe');
    if FileExists(RPath) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function InitializeSetup(): Boolean;
var
  Msg: String;
begin
  Result := True;
  
  if not IsRInstalled() then
  begin
    Msg := 'R is not installed on your system!' + #13#10 + #13#10 +
           'This Lightweight version requires R to be installed.' + #13#10 + #13#10 +
           'Options:' + #13#10 +
           '1. Click YES to download R now, then run this installer again.' + #13#10 +
           '2. Click NO to download the Standalone version (includes R).' + #13#10 + #13#10 +
           'Download R now?';
    
    case MsgBox(Msg, mbConfirmation, MB_YESNOCANCEL) of
      IDYES:
        begin
          ShellExec('open', 'https://cran.r-project.org/bin/windows/base/', '', '', SW_SHOW, ewNoWait, i);
          Result := False;
        end;
      IDNO:
        begin
          ShellExec('open', 'https://github.com/lastnight030506/enviroanalyzer-pro/releases', '', '', SW_SHOW, ewNoWait, i);
          Result := False;
        end;
      IDCANCEL:
        Result := False;
    end;
  end;
end;
