# Windows Sysmon Deployment

Installing Windows Sysmon in distributed environments (Windows domains) can be somewhat tricky, specially when we care about security risks. In this documentation file you'll find information on how to deploy Widows Sysmon in a secure manner.

Special thanks to `arkoperator` (Carlos Perez) from `TrustedSec LLC.` in his  project [`SysmonCommunityGuide`](https://github.com/trustedsec/SysmonCommunityGuide/tree/master) as one of the best resources of information regarding Windows Sysmon.

## Install Windows Sysmon in a Windows Domain with a StartUp Script

To install Windows Sysmon in a Windows Domain follow the steps outlined next:

1. Create a shared folder with `read/execute` permissions for the users and workstations you are considering for this installation. You can name the folder `SysmonArchives` or something similar.
    - If using a DC, you can go to the `shares` tab in the Server Manager and right-click to create a shared folder using the Wizard.
    - You can also create a folder and right-click on `properties` to configure the sharing options.
    - For security reasons, make sure that normal users cannot modify or add any file to the remote share.

![Network Share](/media/servermanager_shares_sysmonarchive.png)

2. In the shared folder, you will save the Windows Sysmon version you are planning to use, often the [latest release](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon). Ideally, you will also save any other previous version.
    - Save every Sysmon version in a folder with the following suggested naming convention: `SysmonV<VERSION>`. For example, the current versions while I am writing this document is 15.15; thus, the folder name will be `SysmonV15.15`.
    - Within each Sysmon folder store the Sysmon executable for that version. You don't need to keep all three executables (Only the one you need per your environment needs, nor the EULA file).

![Sysmon Archive Folder Structure](/media/sysmon_archive_folder.png)

3. In the root of the SysmonArchive folder you must save the [following script](./../sysmon-installer.ps1):

```PowerShell
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
```

4. Create a GPO with the suggested name `Install and Configure Windows Sysmon` (The steps to distribute the configuration of Sysmon are defined [here](#distribute-sysmon-configuration-securely))
    - If you have another naming convetion for your GPOs, feel free to make the changes.

5. In the GPO editor, go to `Computer Configuration > Policies > Windows Settings > Scripts > Startup` and create a startup script.
    - Configure the script in the **Scripts** tab, not the PowerShell Scripts tab. Scripts in the PowerShell Scripts tab are blocked on hosts whose Execution Policy is `Restricted` (the default on Windows clients).
    - Script name: `powershell.exe`
    - Script parameters: `-NoProfile -ExecutionPolicy Bypass -File \\hostname.subdomain.domain.tld\SysmonArchive\sysmon-installer.ps1`
    - Make sure you configure the network path and not the local path. A network path begins with two backslashes (`\\`).

![Configure GPO Startup Script](/media/startup_script_sysmoninstaller.png)

6. Finally, you can manually apply the GPO by running the command `gpupdate` or wait around 90 minutes (default time to wait until GPOs are automatically evaluated and applied). Keep in mind that the script will only run on startup, so you'll need to restart the workstations to install Sysmon.

### Can I set up a schedule task instead of a startup script?

Yes, you can. However, you'll need to configure the Execution Policy settings and sign the PowerShell script.

Ideally, in enterprise environments you'll sign the PowerShell script with a certificate issued by your internal PKI, but for testing you can also search for self-signed PowerShell Scripts. Anyway, this process is out-of-scope of this repository.

Another, not really good option is to set the Execution Policy to `Bypass` in the whole domain, but that's pretty dangerous. Altough the Execution Policy isn't an actual security measure nor security control, allowing any script to run in your domain without warning messages is a bad practice. However, if you plan to make a quick installation for once, this could be a quick and simple option.

### Can I use Desired Configuration State (DSC) to install (and configure) Sysmon?

Yes. I'll add documentation about this soon.

## Distribute Sysmon Configuration securely

Often, people will include the Sysmon XML configuration file in a shared folder and use a similar script like the one showed in earlier sections to push and run that configuration in every Sysmon instance within a computer domain.

Altough this works in terms of operation, there are various security risks when doing so, but the most important is having the configuration file in a shared folder. This is basically exfiltration of sensitive data, and any client, user, and adversary will be able to read that information (hiding the share is not going to work either).

Fortunately, there is a clever and paradogically not-intricate way to push Sysmon configuration to every workstation in a Windows Domain without the need to share the XML file with everybody. You only need to have Windows Sysmon installed and configured in one machine (Ideally your DC).

1. Create a GPO. If you followed the steps in the section to [Install Windows Sysmon with a StartUp script](#install-windows-sysmon-in-a-windows-domain-with-a-startup-script), you may already have the `Install and Configure Windows Sysmon` GPO.

2. Go to `Preferences > Windows Settings > Registry` and right-click to `New > Registry Wizard`.
    - Select the computer that has Windows Sysmon already configured (likely the local computer).
    - Traverse the registry up to this location: `Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SysmonDrv\Parameters`
    - Click the `Parameters` key and the keys under it, including `Rules`,`Options`,`HashingAlgorithm`,`DnsLookup`,`ConfigHash`,`CheckRevocation`.

![](/media/sysmon_distributeconfig_registry.png)

3. Finally, you can apply the GPOs manually using the command `gpupdate` or wait until the GPO is applied automatically. Additionally, registry keys are applied automatically on GPO evaluation; thefore, there is no need to restart the workstations.
Keep in mind the following constraints:

- Keep the action of the registry items as `Update`, so every GPO refresh re-applies the configuration.
- The `Rules` value is a binary blob tied to the Sysmon version. Every workstation must run the same Sysmon version as the reference machine.
- If you renamed the driver with `-d`, the key path is `Services\<driver name>\Parameters` instead of `Services\SysmonDrv\Parameters`.
- After changing the configuration on the reference machine, run the Registry Wizard again so the GPO carries the new values.
- A fresh install with `-i` writes the default rules over the GPO values. The installer script forces a `gpupdate` after installing to re-apply them.
