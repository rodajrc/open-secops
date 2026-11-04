<#
.SYNOPSIS
    Sysmon Installation and Upgrade Script (GPO-compatible).

.DESCRIPTION
    This PowerShell script automates the installation or upgrade of Sysmon (System Monitor) on Windows endpoints.

    It compares the installed driver version with the desired version and installs or upgrades Sysmon accordingly.
    Designed to be used with GPO startup scripts or automated deployment processes.

    The script references a network share for the Sysmon binary.
    The Sysmon configuration is distributed separately through GPO registry preferences.

.VERSION
    0.2

.AUTHOR
    Modified by Alejandro Rodriguez.
    Original script authored by Carlos Perez from TrustedSec LLC (https://www.trustedsec.com), under the MIT License.

.LICENSE
    MIT License (https://opensource.org/licenses/MIT)
    Copyright (c) TrustedSec LLC

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

.NOTES
    Tested with Sysmon version 15.15.
    Run it as a GPO computer startup script from the Scripts tab (not the PowerShell Scripts tab):
        Script name: powershell.exe
        Parameters:  -NoProfile -ExecutionPolicy Bypass -File \\<ShareHost>\SysmonArchive\sysmon-installer.ps1
#>

# --- Configuration -----------------------------------------------------------

# FQDN of the server that hosts the SysmonArchive share
$ShareHost      = '<ShareHost>'      # E.g. dc01.corp.example.com
# Name of the share that holds the Sysmon binaries
$SharedFolder   = 'SysmonArchive'    # Change if necessary
# Approved Sysmon version; must match the driver FileVersion. Type just the number 'XX.YY', e.g. '15.15'
$Version        = '15.15'
# Binary to run: Sysmon64.exe for x64 hosts, Sysmon64a.exe for ARM64, Sysmon.exe for x86
$ExecutableName = 'Sysmon64.exe'
# Driver file name; changes only if Sysmon was installed with -d <name>
$DriverName     = 'SysmonDrv.sys'

# DO NOT MODIFY BELOW THIS LINE (Unless necessary)

# --- Paths -------------------------------------------------------------------

# UNC path to the approved binary: \\<ShareHost>\SysmonArchive\SysmonV<XX.YY>\Sysmon64.exe
$SysmonPath = "\\$ShareHost\$SharedFolder\SysmonV$Version\$ExecutableName"
# Local path where Sysmon places its driver (C:\Windows\SysmonDrv.sys)
$DriverPath = Join-Path $env:windir $DriverName

# --- Install or upgrade ------------------------------------------------------

# The driver file exists only when Sysmon is already installed
if (Test-Path -Path $DriverPath -PathType Leaf) {
    # Read the installed version from the driver file metadata
    $HostVersion = (Get-Item $DriverPath).VersionInfo.FileVersion

    # Installed version is the approved one: nothing to do
    if ($HostVersion -eq $Version) { exit 0 }

    # Different version: uninstall it first.
    # -Wait blocks until the uninstall finishes, so the install below cannot overlap it.
    Start-Process -FilePath $SysmonPath -ArgumentList '-u' -WindowStyle Hidden -Wait
}

# Install the approved version (new host, or after the uninstall above).
# -accepteula suppresses the license prompt; -i installs the service and driver
# with the default configuration. -Wait blocks until the install finishes.
Start-Process -FilePath $SysmonPath -ArgumentList '-accepteula', '-i' -WindowStyle Hidden -Wait

# --- Apply configuration -----------------------------------------------------

# -i wrote default rules to the registry. Force a computer policy refresh so the
# GPO registry preferences overwrite them with the approved configuration now,
# instead of at the next background refresh (90-120 min). Runs without -Wait so
# the startup script does not block on policy processing.
Start-Process -FilePath 'gpupdate.exe' -ArgumentList '/target:computer', '/force' -WindowStyle Hidden
