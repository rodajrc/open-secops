<#
.SYNOPSIS
    Compiles a WEC (.man) Event Manifest file into a usable DLL with RC/MC/CSC toolchain.

.DESCRIPTION
    This script automates the compilation of a Windows Event Collector (WEC) manifest (.man file)
    into a DLL resource using the Microsoft Message Compiler (MC.exe), Resource Compiler (RC.exe),
    and the .NET C# compiler (CSC.exe). The script validates tool availability, handles user input
    for selecting compiler paths, and guides the compilation process step-by-step.

.PARAMETER ManPath
    Optinal Path to the manifest (.man) file that defines the event channels and providers.
    Specify this parameter only if you did not used the script Write-EventManifestFile with the default 
    $CustomEventsMAN parameter.

.PARAMETER CscPath
    Optional path to the .NET C# compiler (csc.exe). If not specified, the script searches for valid versions.

.PARAMETER McPath
    Optional path to the Microsoft Message Compiler (mc.exe). If not specified, the script searches under SDK root.

.PARAMETER RcPath
    Optional path to the Windows Resource Compiler (rc.exe). If not specified, the script searches under SDK root.

.EXAMPLE
    Build-WecEventManifestDll

.EXAMPLE
    Build-WecEventManifestDll -ManPath "C:\MyManifests\CustomEvent.man"

.NOTES
    Author: AzJRC
    Created: June 04, 2025
    Version: 1.0
    Requires: PowerShell 5.1 or later

.NOTES
    Compilation and deployment logic adapted from the project `wef-guidance` made by `t0x01` and `Anton Kutepov`. See RELATED LINKS.

.LINK
    https://github.com/Security-Experts-Community/wef-guidance/tree/main/EventChannelsCollections
#>
function Build-WecEventManifestDll {
    param(
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to the manifest document.")]
        [Alias("Man")]
        [ValidateScript({ Test-ValidateFile $_ '.man' })]
        [string]
        $ManPath = "$PSScriptRoot\..\Files\CustomEventChannels.man",

        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to CSC.exe.")]
        [string]
        $CscPath,

        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to MC.exe.")]
        [string]
        $McPath,

        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to RC.exe.")]
        [string]
        $RcPath
    )

    # Validate prerequisites
    $Executables = Test-ManifestCompilationPrerequisites
    if ($Executables -eq 1) { return }

    $CscPath = Resolve-ExecutablePath -Name "CSC" -AvailablePaths $Executables.CSC -CurrentValue $CscPath
    $McPath = Resolve-ExecutablePath -Name "MC" -AvailablePaths $Executables.MC -CurrentValue $McPath
    $RcPath = Resolve-ExecutablePath -Name "RC" -AvailablePaths $Executables.RC -CurrentValue $RcPath

    $ChoosenExecutables = @{
        CSC = $CscPath
        MC  = $McPath
        RC  = $RcPath
    }

    # Start compilation process with the choosen executable paths (CSC.exe, MC.exe, and RC.exe).
    # We also pass the filename of the Manifest file, which is used as the convention to name the
    # new generated files, and the parent folder where the Manifest file is located, to be used as 
    # the working directory. This is important to ensure all files are generated in the same destination.
    Invoke-CompilationProcess $ChoosenExecutables $((Get-Item $ManPath).Basename) $(Split-Path $ManPath -Parent)
    Write-Host "Compilation success" -ForegroundColor Cyan
}

function Invoke-CompilationProcess {
    param(
        [hashtable]$Executables,
        [string]$ManFilename,
        [string]$WorkingDir
    )

    # Step 1: Run MC.exe to generate message header (.h), binary (.bin), and resource (.rc) files from the manifest
    Write-Host "Running MC.exe - Step 1" -ForegroundColor Cyan
    Start-Process -FilePath $Executables.MC -ArgumentList @($ManPath) -WorkingDirectory $WorkingDir -Wait -NoNewWindow

    # Step 2: Run MC.exe with -css to generate the C# source file for a dummy provider (required by csc)
    Write-Host "Running MC.exe - Step 2" -ForegroundColor Cyan
    Start-Process -FilePath $Executables.MC -ArgumentList @("-css", "$ManFilename.DummyEvent", $ManPath) -WorkingDirectory $WorkingDir -Wait -NoNewWindow

    # Step 3: Run RC.exe to compile the .rc resource script into a .res file required for DLL generation
    Write-Host "Running RC.exe - Step 3" -ForegroundColor Cyan
    Start-Process -FilePath $Executables.RC -ArgumentList @("$ManFilename.rc") -WorkingDirectory $WorkingDir -Wait -NoNewWindow

    # Step 4: Run CSC.exe to compile the .cs file and .res file into a final .NET DLL for use in manifest registration
    Write-Host "Running CSC.exe- Step 4" -ForegroundColor Cyan
    Start-Process -FilePath $Executables.CSC -ArgumentList @(
        "/win32res:$ManFilename.res",
        "/unsafe",
        "/target:library",
        "/out:$ManFilename.dll",
        "$ManFilename.cs"
    ) -WorkingDirectory $WorkingDir -Wait -NoNewWindow
}

#
# Utility functions
#

function Test-ValidateFile {
    param (
        [string]$ManPath,
        [string]$Extension
    )

    if (-not (Test-Path $ManPath)) {
        throw "The file '$ManPath' does not exist."
    }

    if ([System.IO.Path]::GetExtension($ManPath) -ne $Extension) {
        throw "File must have a '$Extension' extension."
    }

    return $true
}

function Test-ManifestCompilationPrerequisites {
    # Paths
    $dotNetRoots = @(
        "C:\Windows\Microsoft.NET\Framework",
        "C:\Windows\Microsoft.NET\Framework64"
    )
    $WinDevKitRoot = "C:\Program Files (x86)\Windows Kits\10\bin"

    # Validate binaries
    $cscPaths = @()
    foreach ($root in $dotNetRoots) {
        if (Test-Path $root) {
            $found = Get-ChildItem -Path $root -Recurse -Filter "csc.exe" -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName
            $cscPaths += $found
        }
    }
    $mcPaths = Get-ChildItem -Path $WinDevKitRoot -Recurse -Filter "mc.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    $rcPaths = Get-ChildItem -Path $WinDevKitRoot -Recurse -Filter "rc.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

    if ($cscPaths.Count -eq 0) {
        Write-Warning "The 'csc.exe' compiler was not found"
        Write-Warning "Unknown error. You may want to try install a new .NET SDK or investigate your issue."

        return 1
    }

    if ($mcPaths.Count -eq 0 -or $rcPaths.Count -eq 0) {
        Write-Warning "Either of the executables 'rc.exe' or 'mc.exe' were not found under $WinDevKitRoot."
        Write-Host "Download the Windows 10 SDK (version 2104 - 10.0.20348.0) from:" -ForegroundColor Cyan
        Write-Host "https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/index-legacy" -ForegroundColor Cyan
           
        $downloadSdk = Read-Host "Would you like to download and install the Windows 10 SDK Version 2104 automatically? [y/N]"
        if ($downloadSdk.ToUpper() -eq 'Y') {
            Invoke-WebRequest "https://go.microsoft.com/fwlink/?linkid=2164145" -OutFile "C:\winsdksetup2104.exe"
            (& "C:\winsdksetup2104.exe")
            Write-Host "Once you finish the installation of the SDK, run the test again" -ForegroundColor Cyan
        }

        return 1
    }

    # Return all paths if needed
    return @{
        CSC = $cscPaths
        MC  = $mcPaths
        RC  = $rcPaths
    }
}

function Resolve-ExecutablePath {
    param (
        [string]$Name, # e.g., "CSC"
        [array]$AvailablePaths, # e.g., $Executables.CSC
        [string]$CurrentValue   # Optional: current path variable (e.g., $CscPath)
    )

    Write-Host "Select your compilers" -ForegroundColor Cyan
    if (-not $CurrentValue) {
        Write-Host "$Name.exe has been found in the following directories:" -ForegroundColor Cyan

        for ($i = 0; $i -lt $AvailablePaths.Count; $i++) {
            Write-Host "[$i] $($AvailablePaths[$i])"
        }

        do {
            $selection = Read-Host "Select $Name.exe path by index"
        } while (-not ($selection -match '^\d+$') -or $selection -ge $AvailablePaths.Count)

        return $AvailablePaths[$selection]
    }

    return $CurrentValue
}

# Run Main
Build-WecEventManifestDll