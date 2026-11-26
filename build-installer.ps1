$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$loveDirectory = Join-Path $env:ProgramFiles "LOVE"
$compiler = Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"
$outputDirectory = Join-Path $projectRoot "dist"
$installerPath = Join-Path $outputDirectory "Gato-vs-Toddys-Setup.exe"
$workDirectory = Join-Path $env:TEMP ("GatoVsToddys-" + [Guid]::NewGuid().ToString("N"))
$sourceDirectory = Join-Path $workDirectory "source"
$appDirectory = Join-Path $workDirectory "app"

if (-not (Test-Path -LiteralPath $compiler -PathType Leaf)) {
    throw "Inno Setup was not found at: $compiler"
}

if (-not (Test-Path -LiteralPath (Join-Path $loveDirectory "love.exe") -PathType Leaf)) {
    throw "LÖVE for Windows was not found at: $loveDirectory"
}

$gameFiles = @("main.lua", "game.lua", "audio.lua", "interface.lua")
foreach ($file in $gameFiles) {
    $sourcePath = Join-Path $projectRoot $file
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Required game file was not found: $sourcePath"
    }
}

$gameIcon = Join-Path $projectRoot "packaging\game-icon.ico"
if (-not (Test-Path -LiteralPath $gameIcon -PathType Leaf)) {
    throw "Required game icon was not found: $gameIcon"
}

$runtimeFiles = @(
    "love.exe",
    "love.dll",
    "lua51.dll",
    "mpg123.dll",
    "msvcp120.dll",
    "msvcr120.dll",
    "OpenAL32.dll",
    "SDL2.dll",
    "license.txt"
)
foreach ($file in $runtimeFiles) {
    $runtimePath = Join-Path $loveDirectory $file
    if (-not (Test-Path -LiteralPath $runtimePath -PathType Leaf)) {
        throw "Required LÖVE runtime file was not found: $runtimePath"
    }
}

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $sourceDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $appDirectory -Force | Out-Null

try {
    foreach ($file in $gameFiles) {
        Copy-Item -LiteralPath (Join-Path $projectRoot $file) -Destination $sourceDirectory
    }

    $confFile = Join-Path $projectRoot "conf.lua"
    if (Test-Path -LiteralPath $confFile -PathType Leaf) {
        Copy-Item -LiteralPath $confFile -Destination $sourceDirectory
    }

    Copy-Item -LiteralPath (Join-Path $projectRoot "assets") -Destination $sourceDirectory -Recurse

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $loveArchive = Join-Path $workDirectory "Gato vs Toddys.love"
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $sourceDirectory,
        $loveArchive,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )
    Copy-Item -LiteralPath $loveArchive -Destination $appDirectory
    Copy-Item -LiteralPath $gameIcon -Destination (Join-Path $appDirectory "game-icon.ico")

    foreach ($file in $runtimeFiles) {
        Copy-Item -LiteralPath (Join-Path $loveDirectory $file) -Destination $appDirectory
    }

    $escapedAppDirectory = $appDirectory.Replace("\", "\\")
    $escapedOutputDirectory = $outputDirectory.Replace("\", "\\")
    $issText = @"
#define AppName "Gato vs Toddys"
#define AppVersion "1.0.2"
#define SourceDir "$escapedAppDirectory"
#define OutputDir "$escapedOutputDirectory"

[Setup]
AppId={{9A4BA7BD-1C57-4D47-91F6-4D2B9E50A8A1}}
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
DisableDirPage=no
UsePreviousAppDir=yes
SetupIconFile={#SourceDir}\game-icon.ico
UninstallDisplayIcon={app}\game-icon.ico
OutputDir={#OutputDir}
OutputBaseFilename=Gato-vs-Toddys-Setup
SetupLogging=yes
PrivilegesRequired=lowest
WizardStyle=modern
Compression=lzma2
SolidCompression=yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na area de trabalho"; GroupDescription: "Atalhos:"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\love.exe"; Parameters: """{app}\Gato vs Toddys.love"""; WorkingDir: "{app}"; IconFilename: "{app}\game-icon.ico"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\love.exe"; Parameters: """{app}\Gato vs Toddys.love"""; WorkingDir: "{app}"; IconFilename: "{app}\game-icon.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\love.exe"; Parameters: """{app}\Gato vs Toddys.love"""; Description: "Iniciar Gato vs Toddys"; Flags: postinstall nowait skipifsilent
"@

    $issPath = Join-Path $workDirectory "installer.iss"
    $encoding = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($issPath, $issText, $encoding)

    & $compiler "/Qp" $issPath
    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup failed with exit code $LASTEXITCODE"
    }

    if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
        throw "The installer was not created at: $installerPath"
    }

    Get-Item -LiteralPath $installerPath | Select-Object FullName, Length
}
finally {
    if (Test-Path -LiteralPath $workDirectory) {
        Remove-Item -LiteralPath $workDirectory -Recurse -Force
    }
}
