; This script requires Inno Setup Compiler 5.5.6 or later to compile
; The Inno Setup Compiler (and IDE) can be found at http://www.jrsoftware.org/isinfo.php
; The IDP plugin for Inno Setup is also required and can be found at https://mitrichsoftware.wordpress.com/inno-setup-tools/inno-download-plugin/

#include <idp.iss>

#define MyAppName "Microsoft Git Credential Manager for Windows"
#define MyAppVersion "1.2.0"
#define MyAppPublisher "Microsoft Corporation"
#define MyAppPublisherURL "http://www.microsoft.com"
#define MyAppURL "https://github.com/Microsoft/Git-Credential-Manager-for-Windows"
#define MyAppExeName "git-credential-manager.exe"
#define Git4WinName "Git for Windows 2.7.2"
#define Git4WinUrl "https://github.com/git-for-windows/git/releases/download/v2.7.2.windows.1/Git-2.7.2-64-bit.exe"
#define Git4WinFile "Git-2.7.2-64-bit.exe"
#define Git4WinSpace 394309632
#define NetFxName "The Microsoft .NET Framework 4.6.1"
#define NetFxBaseFile "NetFx40Installer.exe"
#define NetFxBaseUrl "http://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe"
#define NetFxCoreFile "NetFx46Installer.exe"
#define NetFxCoreUrl "https://download.microsoft.com/download/3/5/9/35980F81-60F4-4DE3-88FC-8F962B97253B/NDP461-KB3102438-Web.exe"
#define NetFxSpace 381005824

[Setup]
AppId={{9F0CBE43-690B-4C03-8845-6AC2CDB29815}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppPublisherURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright=Copyright � Microsoft 2016
AppReadmeFile=https://github.com/Microsoft/Git-Credential-Manager-for-Windows/blob/master/README.md
BackColor=clWhite
BackSolid=yes
DefaultDirName={userpf}\{#MyAppName}
LicenseFile=..\Deploy\LICENSE.TXT
OutputBaseFilename=GCMW-1.2.0
Compression=lzma2
InternalCompressLevel=ultra64
SolidCompression=yes
MinVersion=6.1.7600
DisableDirPage=yes
DisableReadyPage=yes
SetupIconFile=Assets\gcmicon.ico
ArchitecturesInstallIn64BitMode=x64
WizardImageBackColor=clWhite
WizardImageFile=Assets\gcmicon128.bmp
WizardSmallImageFile=Assets\gcmicon64.bmp
WizardImageStretch=no
WindowResizable=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl";

[Types]
Name: "full"; Description: "Full installation"; Flags: iscustom;

[Components]
Name: "NetFx"; Description: {#NetFxName}; ExtraDiskSpaceRequired: {#NetFxSpace}; Types: full; Flags: fixed; Check: DetectNetFxChecked;
Name: "Git4Win"; Description: {#Git4WinName}; ExtraDiskSpaceRequired: {#Git4WinSpace}; Types: full; Flags: fixed; Check: DetectGitChecked;

[Dirs]
Name: "{tmp}\gcmSetup"

[Files]
Source: "..\Deploy\git-credential-manager.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Deploy\Microsoft.Alm.Authentication.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Deploy\Microsoft.Alm.Git.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Deploy\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Deploy\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Deploy\README.md"; DestDir: "{app}"; Flags: ignoreversion

[UninstallDelete]
Type: files; Name: "{app}\git-credential-manager.exe";
Type: files; Name: "{app}\Microsoft.Alm.Authentication.dll";
Type: files; Name: "{app}\Microsoft.Alm.Git.dll";
Type: files; Name: "{app}\Microsoft.IdentityModel.Clients.ActiveDirectory.dll";
Type: files; Name: "{app}\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll";
Type: files; Name: "{app}\README.md";

[Code]
type NetFx_Version = (
     NetFx_v30,  // .NET Framework 3.0
     NetFx_v35,  // .NET Framework 3.5
     NetFx_v40,  // .NET Framework 4.0
     NetFx_v45,  // .NET Framework 4.5
     NetFx_v451, // .NET Framework 4.5.1
     NetFx_v452, // .NET Framework 4.5.2
     NetFx_v46   // .NET Framework 4.6
     NetFx_v461);// .NET Framework 4.6.1 

function DetectGit(): Boolean;
var
  bSuccess: Boolean;
  strValue: String;
begin
    Result := True;

    bSuccess := RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1', 'InstallLocation', strValue)
             or RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1', 'InstallLocation', strValue)
             or RegQueryStringValue(HKCU, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1', 'InstallLocation', strValue)
             or RegQueryStringValue(HKCU, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1', 'InstallLocation', strValue);

    if not bSuccess then
      begin
        Result := False;
      end;
end;

function DetectGitChecked(): Boolean;
begin
  Result := not DetectGit();
end;

function DetectNetFx(version: NetFx_Version): Boolean;
var
  bSuccess: Boolean;
  regVersion: Cardinal;
begin
  Result := False;

  bSuccess := RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0', 'Install', regVersion);

  if (NetFx_v30 = version) and bSuccess then
    begin
      Result := True;
    end;

  bSuccess := RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5', 'Install', regVersion);

  if (NetFx_v35 = version) and bSuccess then
    begin
      Result := True;
    end;

  bSuccess := RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4.0\Full', 'Install', regVersion)
           or RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4.0\Client', 'Install', regVersion);

  if (NetFx_v40 = version) and bSuccess then
      begin
        Result := True;
      end;

  bSuccess := RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', regVersion)
           or RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client', 'Release', regVersion);

  if bSuccess then
    begin
      if (NetFx_v45 = version) and (regVersion >= 378389)then
        begin
          Result := True;
        end;

      if (NetFx_v451 = version) and (regVersion >= 378675)then
        begin
          Result := True;
        end;

      if (NetFx_v452 = version) and (regVersion >= 379893)then
        begin
          Result := True;
        end;

      if (NetFx_v46 = version) and (regVersion >= 393295) then
        begin
          Result := True;
        end;

      if (NetFx_v461 = version) and (regVersion >= 394254) then
        begin
          Result := True;
        end;
    end;
end;

function DetectNetFxChecked(): Boolean;
begin
  Result := not DetectNetFx(NetFx_v451);
end;

function InstallPrerequisites() : Boolean;
var
  bInstallFx40: Boolean;
  bInstallFx461: Boolean;
  bInstallGit: Boolean;
  StatusText: string;
  ResultCode: Integer;
begin
  Result := True;

  bInstallFx40 := FileExists(ExpandConstant('{tmp}\{#NetFxBaseFile}'));
  bInstallFx461 := FileExists(ExpandConstant('{tmp}\{#NetFxCoreFile}'));
  bInstallGit := FileExists(ExpandConstant('{tmp}\{#Git4WinFile}'));

  if bInstallFx40 or bInstallFx46 then
    begin
      StatusText := WizardForm.StatusLabel.Caption;
      WizardForm.StatusLabel.Caption := 'Installing {#NetFxName}. This might take a few minutes...';
      WizardForm.ProgressGauge.Style := npbstMarquee;

      try
        if bInstallFx40 then
          begin
            if not Exec(ExpandConstant('{tmp}\{#NetFxBaseFile}'), '/passive /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
              begin
                Result := False;
                MsgBox('.NET installation failed with code: ' + IntToStr(ResultCode) + '.', mbError, MB_OK);
              end;
          end;

        if bInstallFx461 then
          begin
            if not Exec(ExpandConstant('{tmp}\{#NetFxCoreFile}'), '/passive /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
              begin
                Result := False;
                MsgBox('.NET installation failed with code: ' + IntToStr(ResultCode) + '.', mbError, MB_OK);
              end;
          end;
      finally
        WizardForm.StatusLabel.Caption := StatusText;
        WizardForm.ProgressGauge.Style := npbstNormal;
      end;
    end;

  if bInstallGit then
    begin
      StatusText := WizardForm.StatusLabel.Caption;
      WizardForm.StatusLabel.Caption := 'Installing {#Git4WinName}. This might take a few minutes...';
      WizardForm.ProgressGauge.Style := npbstMarquee;

      try
        if not Exec(ExpandConstant('{tmp}\{#Git4WinFile}'), '/NOCANCEL', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
          begin
            Result := False;
            MsgBox('Installing Git for Windows failed with code: ' + IntToStr(ResultCode) + '.', mbError, MB_OK);
          end;
      finally
        WizardForm.StatusLabel.Caption := StatusText;
        WizardForm.ProgressGauge.Style := npbstNormal;
      end;
    end;
end;

function InstallManager() : Boolean;
var
  ResultCode: integer;
  StatusText: string;
begin
  Result := False;

  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := 'Installing {#MyAppName}.';
  WizardForm.ProgressGauge.Style := npbstMarquee;

  try
    if Exec(ExpandConstant('{app}\git-credential-manager.exe'), 'deploy --passive --nofail', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      begin
        Result := True;
      end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;     
end;

function UninstallManager() : Boolean;
var
  ResultCode: integer;
  StatusText: string;
begin
  Result := false;

  if Exec(ExpandConstant('{app}\git-credential-manager.exe'), 'remove --passive --nofail', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      Result := True;
    end;
end;

function InitializeUninstall(): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard;
begin
  if not DetectNetFx(NetFx_v40) then
    begin
      idpAddFile('{#NetFxBaseUrl}', ExpandConstant('{tmp}\{#NetFxBaseFile}'));
      idpDownloadAfter(wpReady);
    end;

  if not DetectNetFx(NetFx_v451) then
    begin
      idpAddFile('{#NetFxCoreUrl}', ExpandConstant('{tmp}\{#NetFxCoreFile}'));
      idpDownloadAfter(wpReady);
    end;

  if not DetectGit() then
    begin
      idpAddFile('{#Git4WinUrl}', ExpandConstant('{tmp}\{#Git4WinFile}'));
      idpDownloadAfter(wpReady);
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  case CurStep of
    ssInstall:
      begin
        if not (InstallPrerequisites()) then
          begin
            Abort();
          end;
      end;

    ssPostInstall:
      begin
        if not (InstallManager()) then
          begin
            RaiseException('Fatal: An error occured when updating the local system.');
          end;
      end;
  end;  
end;

procedure CurUninstallStepChanged(CurStep: TUninstallStep);
begin
  case CurStep of
    usUninstall:
      if not (UninstallManager()) then
        begin
          Abort();
        end;
    end;
end;

