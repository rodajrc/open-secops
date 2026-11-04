# Windows Event Forwarding Guide

In this section of the repository you'll find everything I know about Windows Event Forwarding (WEF). I'll try to keep this section updated with new discoveries, recommendations, configuration guides, and resources.

## What's Windows Event Forwarding

WEF is a functionality embedded in the Windows Operating System that simplifies the process of centralizing Windows Event Logs. As with other solutions, WEF has various benefits and caveats. Let's describe WEF by enlisting the good and bad things of it.

|                                                           Advantage                                                           |                                                                       Disadvantage                                                                      |
|:-----------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------:|
|      WEF does not require software installation of any kind; it uses built-in features and capabilities of the Windows OS     | Although it is not mandatory, WEF is highly recommended to be configured in an environment with a Domain Controller (DC)                                |
|                                     WEF can be configured and deployed in just few minutes                                    | In really big environments, WEF could require more strict policies and careful implementation to keep the environment secure                            |
|    Centralized events offer the possibility to threat hunters and security analyst to inspect the Windows Domain seamlessly   | WEF cannot be configured to forward the events to a third-party solution. It can only forward the events to another Windows System.                     |
| Implementing an agentless architecture with WEF minimizes security risks, like agent overhead or expanding the attack surface | You'll need deep knowledge of the Windows OS and Windows capabilities to be able to support and troubleshoot WEF. Agents are easier to manage than WEF. 

One of the best resource I have found in the Microsoft Official Documentation that introduces WEF pretty well is [here](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/use-windows-event-forwarding-to-assist-in-intrusion-detection). I encourage you to read about WEF in that resource.

### Collectors and Forwarders

Windows Event Forwarding depends on two main components: Windows Event Collectors (WECs) and Windows Event Forwarders (or WEF clients). The former are the chosen workstations or servers that will collect the Windows Event Logs from the WEF clients.

According to Microsoft documentation, a unique WEC can support around 3000 events per second, but this is very subjective (There is no mention of the specs of the computer receiving the events). However, most community-based suggestions and recommendations say that a WEC can indeed allocate around 2000 to 4000 workstations.

A well deployed WEF architecture will load balance event forwarding in enough WECs, and also will ensure that the forwarded events are filtered on advance to minimize noise and reduce the consumption of space in the collectors.

## Configuration and Deployment

### Configuration through GPOs

Windows Event Forwarding is often configured in Windows Domains, as this makes the implementation more straightforward and simple. Follow the steps to set up WEF successfully.


1. **Determine the number of WECs you will need in your environment**

Plan for one WEC per 2,000 to 4,000 WEC clients (see [Collectors and Forwarders](#collectors-and-forwarders)). Beyond that range, or when a collector cannot keep up with the event rate, add WECs and split the clients between them using security groups.

2. **Enable WinRM in your WECs and WEC clients**

![](/media/wef_enablewinrm.png)

3. **Configure the WEC URI in your clients**

![](/media/wef_configurewectarget.png)

4. **Allow the Network Service to read the Security Event Log**

![](/media/wef_securitylogaccesssddl.png)

`O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;NS)`

5. **Create a source-initiated subscription**

On the WEC:

1. Run `wecutil qc` to configure and start the Windows Event Collector service.
2. Open Event Viewer, right-click `Subscriptions` and select `Create Subscription`.
3. Select `Source computer initiated` and click `Select Computer Groups` to add the security group that contains the WEC clients' computer accounts.
4. Click `Select Events` and choose the logs or paste an XML query (for example, one from the [WEF Management Tool QueriesDB](./WefManagementTool/QueriesDB)).
5. Keep `Forwarded Events` as the destination log, or select a custom channel.
6. Under `Advanced`, choose the delivery optimization (`Normal`, `Minimize Bandwidth` or `Minimize Latency`).

6. **Troubleshoot and test**

Once you implemented everything, you must likely find that the service isn't working as expected. In bad scenarios you will likely see a warning sign (`⚠️`) meaning that the collector subscriptions didn't work for some reason.

In any case, you have two important sources of information to troubleshoot Windows Event Forwarding itself. Review the logs:

1. `Microsoft-Windows-Eventlog-ForwardingPlugin/Operational`: Provides information about forwarding issues. You will want to review this log file in the WEC clients, but often events can also generate in the WEC too, and will appear here.
2. `Microsoft-Windows-EventCollector/Operational`: Provides information about the collector. As a personal side note, during my tests, I found events in this log in very rare occasions.

Depending on the issues you are having you'll find various events that may help you track the issue with WEF. As a suggestion, always verify that:

1. You do not have connection issues.
    - Try pinging your WEC from a client (You'll need to allow ICMP in the Firewall of the WEC).
    - It is even better if you try with `winrm`. Use the command `winrm identify -remote:<WEC Hostname>` to check if the WinRM service is running in the WEC server.
2. The appropriate settings are applied in the problematic computer.
    - This includes Security Groups (SG) and Group Policy Objects (GPOs). Remember that computer settings enforced via GPO often require system reboot to be applied. The same occurs with SG whose members are computer objects.
    - If using a DC to enforce settings across systems, verify using the command `gpresult`. Use the parameters `/scope:computer /r` to get a summary of the computer settings.
3. Try rebooting your computer. Often, some settings need system reboot to apply changes or reevaluate domain resources (like kerberos tickets).
4. If none of this resolves your issues, your problem may be more case-specific. Review the following subsections and identify which scenario is more similar to yours.

### URI Misconfiguration

WEF may fail when there is a misconfiguration with the Subscription Manager Address that was set up in the [step 3: Configure the WEC URI in your clients](#configuration-through-gpos).

Review the configuration and make sure you type the correct transport protocol and port. If that's correct, you may have a typo somewhere in the URI.

If the URI is correct, make sure the configuration reached the client computer. It had happened to me that the computer security group membership that is specified when creating subscriptions isn't applied immediately.

### WinRM issues

WEF works on top of another service called Windows Remote Management (WinRM). If you followed the [step 2: Enable WinRM in your WECs and WEC clients](#configuration-through-gpos) you shouldn't have this issue; however, for some reason the service fails anyways.

To troubleshoot, verify in the Windows Defender Firewall with Advanced Security that a rule with the name `Windows Remote Management (HTTP-In)` exists. Also verify that the service `WinRM` is running.

You can use the following commands to make this verification quickly:

```PowerShell
# Search for Windows Defender Firewall rule regarding WinRM
Get-NetFirewallRule | Where-Object { $_.Name -like "WINRM-HTTP-In-TCP*" }

# Verify WinRM service is running
Get-Service -ComputerName localhost -Name WinRM
```

If everything looks fine, it had happened to me that besides having the firewall rule and the service running, WEF won't work anyways. You can do two things in that case:

1. Try rebooting the computer.
2. If a reboot is not feasible, run the command `winrm quickconfig`.

The second option will start a CLI wizard that will autoconfigure WinRM in the host computer. If you get the following output, it means WinRM is set up correctly

```
WinRM service is already running on this machine.
WinRM is already set up for remote management on this computer.
```

### Network Service permissions

If one of your error events contains the message `Access is denied`, it will most likely be a permissions issue.

Make sure that:

1. You configured permissions for the Network Service (NS) to read the log file (surely, the Security log) you are trying to forward. Follow the step [4. Allow the Network Service to read the Security Event Log](#configuration-through-gpos).
2. If you followed the steps, make sure the settings are applied in your computer. You can use this command to review the SDDL of any log file:

```
wevtutil.exe gl <LogName>
```

```PowerShell
# Example of usage of the Windows Event Utility
PS C:\Users\Administrator> wevtutil.exe gl Security
name: Security

[Output omitted]

channelAccess: O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20) 
# (A;;0x1;;;S-1-5-20) -> The Network Service (S-1-5-20) is allowed (A) for read (0x1) operations.

[Remaining output omitted...]
```

3. Changing access rights to a log file requires system restart. Reboot your computer.

### Warning event says that the subscription is created but one or more channels in the query could not be read at this time

If you have this issue, the problem is likely the same as above but the read permissions must be granted to another log file.

Granting read permissions to the Security Log was easy via GPO because there was a specific policy setting where to configure it (there are also GPO settings for the Application, Setup and System logs), but for non-trivial logs we need to do the configuration manually in the registry.

```diff
- Warning: Modifying the registry is dangerous. Make sure to backup your system before touching any registry key if you do not want to break your computer completely.
```

You can check [this webpage](https://learn.microsoft.com/en-us/troubleshoot/windows-server/group-policy/set-event-log-security-locally-or-via-group-policy#configure-event-log-security-locally) for more information on how to grant permissions to an event log via the Windows Registry. It is highly possible that the Event Log Reader group or the Network Service do not have read access to a channel specified in the subscription pointed out in the event message (You can use `wevtutil.exe` to verify).

Based on experience, a subscription will trigger an `EventID 103: The subscription <Subscription Name> is unsubscribed.` in the `Microsoft-Windows-Eventlog-ForwardingPlugin/Operational` log of the WEC client if none of the queries can be executed (because of a client-side issue). The subscription is then moved to a passive *disabled* state.

If at least one query can be executed, instead of an event id 103, the event will be `EventID 101: The subscription <Subscription Name> is created, but one or more channels in the query could not be read at this time.`. Again, the reason of one queries working and others not is very likely to be permission issues with the `Network Service` accessing some privileged or sensitive logs.

### Everything looks fine but my collector still does not have any client connected to it

Often you only need to wait a few minutes and it will connect automatically. If that doesn't work, review again your settings and that everything is set up correctly.

Once I had problem where my WEC subscriptions were assigned to a Security Group that wasn't still enforced in the clients. Remember that most computer settings applied via a DC, including GPOs and SG with computer memberships, require rebooting your system.

### My WEC clients unsubscribe for no apparent reason

You may want to check this [stack overflow post](https://serverfault.com/questions/1136569/two-systems-not-showing-in-windows-event-collector) and [this reddit post](https://www.reddit.com/r/sysadmin/comments/86btj2/windows_event_forwarding_is_there_a_max_number_of/).

## Walkthrough video

I recorded [this video](https://youtu.be/6rhsk8LB2NM) showing the implementation of WEF. (I need to update this video soon).