# Deploy custom event logs

## Write-EventManifestFile Module
`Write-EventManifestFile` assists in the creation of valid ETW-compliant Windows Event Manifest files. It supports interactive and automatic modes, allowing the user to define provider metadata, event channel paths, and symbol naming conventions. This manifest can be later imported using wevtutil or compiled with the Message Compiler (mc.exe).

### How to use?

Upon execution of `Write-EventManifestFile` (without any optional argument), you will be asked to enter the **PROVIDER NAME** that you want to add to windows logs.

```diff
+ [Suggestion] Provider names should follow the pattern [WEC Common Name]-[Context]-[Target]. For example, `Event Collector-Domain-Clents` or 'Event Collector-NonDomain-Servers'. 

+ Using hyphens in the name of the provider will also display the new logs under a directory-like structure in the Event Viewer.
```

After that you can optionally type a **SYMBOL PREFIX**. The symbolic names of the providers and channels are used in code-like applications, out-of-scope of this documentation. 

```diff
+ [Suggestion] Type the hostname of the WEC Server where you plan to deploy the new providers.
```

Finally, you'll be asked to input the **CHANNEL STREAM**.These are the logs' specific names. For example, Sysmon has the log `Microsoft-Windows-Sysmon/Operational`, where the provider is `Microsoft-Windows-Sysmon` and the channel stream is `Operational`.

Although the names of these channels is under the engineer's decision, I personally prefer the following schema:

|       Channel Stream      |                                                         Description                                                         |
|:-------------------------:|:---------------------------------------------------------------------------------------------------------------------------:|
|          System           |                            OS events, hardware, boot, updates, resource usage, registry changes.                            |
|          Network          |                                     Connectivity, firewall, VPN, DNS, internet traffic.                                     |
|    Security & Auditing    |                     Security policy, incidents, audit trails, data integrity checks, regulatory-specific events.            |
| Applications and Services |                                      App logs, service lifecycle, middleware, scripts.                                      |
|     Identity & Access     |                            Account management, login/logout, session tracking, remote management.                           |

*Notes:*
- According to [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/win32/wes/defining-channels) on defining channels, you can specify up to eight channels per event provider. 
- Continuing the above point, it is recommended to keep the number of channels under 8. For instance, in [Palantir's Windows Event Forwarding guidance](https://github.com/palantir/windows-event-forwarding/tree/master/windows-event-channels), they mention that no more than seven channels are added to each provider, adhering to this limitation.
- The suggested channels mapped above have various benefits.
    - They map nearly any log source into one of these categories.
    - It is scalable. You can, for example, add another category like `Configuration & Change Management` or divide the `Security & Auditing` into only `Security` and `Audit & Compliance`. This will depend heavily on your organizational needs.
    - Categories are orthogonal, which means they are well-defined. No overlap or ambiguity.
    - You can always add two (or three, altough not recommended unless estrictly necessary) more custom channels specific to your organizational needs.
- When mapping events to the suggested channel domains, it very important to focus on the intent of the event, rather than the event source channel.
    - Refer to [MS_EVENTS_TO_MONITOR.md](/wef/WefManagementTool/docs/MS_EVENTS_TO_MONITOR.md) to learn more how to do this mapping.

```diff
* Notice: Most sections in this documentation will assume the suggested event log structure explained above
```

Succesful use of the module will generate a `MAN` file like the following:

```XML
<?xml version="1.0"?>
<instrumentationManifest xsi:schemaLocation="http://schemas.microsoft.com/win/2004/08/events eventman.xsd" xmlns="http://schemas.microsoft.com/win/2004/08/events" xmlns:win="http://manifests.microsoft.com/win/2004/08/windows/events" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:trace="http://schemas.microsoft.com/win/2004/08/events/trace">
    <instrumentation>
        <events>
            <provider name="Event Collector-Clients" guid="{5e7e9436-744a-430b-bdc7-dd8822991b57}" symbol="WEC01_EVENT_COLLECTOR_CLIENTS" resourceFileName="C:\Windows\System32\CustomEventChannels.dll" messageFileName="C:\Windows\System32\CustomEventChannels.dll" parameterFileName="C:\Windows\System32\CustomEventChannels.dll">
                <channels>
                    <channel name="Event Collector-Clients/System" chid="EventCollector-Clients/System" symbol="WEC01_EVENT_COLLECTOR_CLIENTS_SYSTEM" type="Admin" enabled="false" />
                    <channel name="Event Collector-Clients/Network" chid="EventCollector-Clients/Network" symbol="WEC01_EVENT_COLLECTOR_CLIENTS_NETWORK" type="Admin" enabled="false" />
                    <channel name="Event Collector-Clients/Security" chid="EventCollector-Clients/Security" symbol="WEC01_EVENT_COLLECTOR_CLIENTS_SECURITY" type="Admin" enabled="false" />
                    <channel name="Event Collector-Clients/Application And Services" chid="EventCollector-Clients/ApplicationAndServices" symbol="WEC01_EVENT_COLLECTOR_CLIENTS_APPLICATION_AND_SERVICES" type="Admin" enabled="false" />
                    <channel name="Event Collector-Clients/Identity And Access" chid="EventCollector-Clients/IdentityAndAccess" symbol="WEC01_EVENT_COLLECTOR_CLIENTS_IDENTITY_AND_ACCESS" type="Admin" enabled="false" />
                </channels>
            </provider>
            <provider name="Event Collector-Servers" guid="{7434f9b6-60c2-44b2-b700-abe2b9fb3c6f}" symbol="WEC01_EVENT_COLLECTOR_SERVERS" resourceFileName="C:\Windows\System32\CustomEventChannels.dll" messageFileName="C:\Windows\System32\CustomEventChannels.dll" parameterFileName="C:\Windows\System32\CustomEventChannels.dll">
                <channels>
                    <channel name="Event Collector-Servers/System" chid="EventCollector-Servers/System" symbol="WEC01_EVENT_COLLECTOR_SERVERS_SYSTEM" type="Admin" enabled="false" />
                    <channel name="Event Collector-Servers/Network" chid="EventCollector-Servers/Network" symbol="WEC01_EVENT_COLLECTOR_SERVERS_NETWORK" type="Admin" enabled="false" />
                    <channel name="Event Collector-Servers/Security" chid="EventCollector-Servers/Security" symbol="WEC01_EVENT_COLLECTOR_SERVERS_SECURITY" type="Admin" enabled="false" />
                    <channel name="Event Collector-Servers/Application and Services" chid="EventCollector-Servers/ApplicationandServices" symbol="WEC01_EVENT_COLLECTOR_SERVERS_APPLICATION_AND_SERVICES" type="Admin" enabled="false" />
                    <channel name="Event Collector-Servers/Identity And Access" chid="EventCollector-Servers/IdentityAndAccess" symbol="WEC01_EVENT_COLLECTOR_SERVERS_IDENTITY_AND_ACCESS" type="Admin" enabled="false" />
                </channels>
            </provider>
        </events>
    </instrumentation>
</instrumentationManifest>
```

Finally, deploy the custom event manifest by running the modules `Build-WecEventManifestDll`, `Install-WecEventManifestDll`, and `Set-WecEventChannels`, in that sequence order.

## Build-WecEventManifestDll Module

This module will use the compiler tools `csc.exe`, `mc.exe`, and `rc.exe` to convert the `MAN` file created with `Write-EventManifestFile` to a `DLL` binary file.

## Install-WecEventManifestDll Module

This module will follow a series of secure steps to install the `DLL` binary file containing the event manifest information to the Windows Event Logs.

Upon successful installation, you will be able to see the new event logs in the Event Viewer application.

## Set-WecEventChannels Module

This module will set up the actual files where the logs are going to be stored. You'll notice that when you executed `Write-EventManifestFile`, a text file `Channels.txt` was generated alongside the `MAN` file. `Write-EventManifestFile` will read this file and use the name of the channels to create the log files, by default under `C:\Event Collector Logs`.