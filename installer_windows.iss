; -- installer_windows.iss --
; This is the installator creator for snaut

#define snautVersion "0.1.5"

[Setup]
AppName=snaut
AppVersion={#snautVersion}
DefaultDirName={pf}\snaut
SetupIconFile=utils\windows\icon.ico
; Since no icons will be created in "{group}", we don't need the wizard
; to ask for a Start Menu folder name:
DisableProgramGroupPage=yes
OutputBaseFilename=snaut-setup-{#snautVersion}
OutputDir=windows_installer

[Files]
Source: "dist\*.*"; DestDir: "{app}" ; Flags: recursesubdirs
; Source: "dist\snaut.bat"; DestDir: "{app}";

[Icons]
Name: "{group}\snaut"; Filename: "{app}\snaut.bat"; WorkingDir: "{app}"; IconFilename: "{app}\icon.ico";
Name: "{commondesktop}\snaut"; Filename: "{app}\snaut.bat"; WorkingDir: "{app}"; IconFilename: "{app}\icon.ico";

[INI]
; this is set using the Pascal code below, it asks for the folder path
Filename: "{app}\config_local.ini"; Section: "semantic_space"; Key: "semspaces_dir"; String: "{code:DataDir}"

[Code]

var DataDirVar : String;

function DataDir(param: String) : String;
var
  Dir : String;
begin
  if DataDirVar = '' then
  begin
    CreateDir(ExpandConstant('{userdocs}\semantic spaces'));
    Dir := ExpandConstant('{userdocs}\semantic spaces');
    BrowseForFolder('Select folder in which you want to store semantic spaces.', Dir, true);
    DataDirVar := Dir;
  end;

  result := DataDirVar;
end;


