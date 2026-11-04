# Query Metadata Schema 1.0

This document describes the standardized schema for `QUERY.XML` metadata files used in this project. These XML files encapsulate structured information about security detection queries, making them portable, versioned, and auditable.

## Objectives

- Establish a consistent format for documenting detection queries.
- Standardize fields to support programmatic parsing and future automation (e.g., audit policy recommendations).
- Facilitate sharing and maintenance of queries across platforms and environments.

## Metadata Structure

Each `QUERY.XML` must include a comment block following this structure:

```xml
<!--
    MetaSchemaVersion:  1.0
    QueryName:          File Sharing Activity
    Intent:
        - Primary:      Security and Auditing
        - Secondary:    Malware
    Platform:           WIN7, WIN10, WIN2016, WIN2019, WIN2022
    SecurityProfile:    Member Server, Workstation
    Author:
        - Name:         Alejandro Rodriguez
        - Alias:        Username/AzJRC
        - Resource:     Github/WefManagementTool
        - Resource:     URL/https://github.com/rodajrc/open-secops
    Reference:
        - Name:         Michel de CREVOISIER
        - Alias:        mdecrevoisier
        - Resource:     Github/Windows-auditing-baseline
        - Resource:     URL/https://github.com/mdecrevoisier/Windows-auditing-baseline
    QueryVersion:       1.0
    QueryDate:          2025-06-27
    Tag:                Technique/T1021.002
    Tag:                Technique/T1222.001
    Tag:                Technique/T1187
    Tag:                Category/Object Access
    Tag:                Subcategory/File Share
    Tag:                Action/Resource Sharing
    Tag:                Misc/SMB
    Tag:                Misc/Admin Shares
    RequiresAudit:      Yes
    RequiredSettings:
        - AuditPolicy:  Object Access/File Share
    Description:        Monitors access and changes to network shares (creation, modification, deletion, and SMB auth failures).
-->
```

## Fields

The following table enlists the mandatory fields of a `QUERY.XML` file.

| Field 	| Description 	|
|---	|---	|
| `MetaSchemaVersion` 	| Version of this metadata schema. Ensures backward compatibility and programmability of scripting tools. 	|
| `QueryName` 	| Human-readable descriptive name of the query. 	|
| `Intent.Primary` 	| Intent of the query. Must be one of the following allowed values: `Security and Auditing`, `Application and Services`, `Identity and Access`, `System`, `Network`. 	|
| `Author` 	| Structured information including at least name or alias of the person that created a query. 	|
| `QueryVersion` 	| Version number in format `X.Y`. Minor changes involve modifying or fixing already declared Select or Suppress tags that do not change the intent of the query. Major changes involve adding new Select or Suppress queries or changes that affect the intent of the query. 	|

The following table enlists the non mandatory (but strictly recommended) fields of a QUERY.XML file.

| Field 	| Description 	| Example value	|
|---	|---	|---	|
| `Intent.Secondary` 	| More granular category, open to interpretation. We suggest using `auditpol` keywords or Mitre Att&ck alike terms. You can declare more than one secondary intent using commas[^1]. You can also use `Intent.Primary` terms if you believe that the query exists between two intent categories.	| `Account Management, Kerberos Operation` 	|
| `Platform` 	| List of operating systems this query applies to. Allowed values include `WIN7`, `WIN8`, `WIN10`, `WIN11`, `WIN2008`, `WIN2012`, `WIN2016`, `WIN2019`, `WIN2022`, and `WIN2025`. 	| `WIN8`, `WIN10`, `WIN2012`, `WIN2016`, `WIN2019`, `WIN2022` 	|
| `SecurityProfile` 	| Roles or asset types relevant for the query. Allowed values include `Domain Controller`, `Member Server`, `Workstation` or `Other`. 	| `Workstation`, `Member Server` 	|
| `Reference` 	| External documentation or advisories. Read the section [Author and Reference structure](#author-and-reference-structure) to use this field effectively.	| - 	|
| `QueryDate` 	| Date of creation or last revision. Dates must use the format `YYYY-MM-DD`. 	| 2025-07-23 	|
| `Verbosity` 	| Declares the verbosity level of the query. Allowed values include `Low`, `Medium`, or `High`. If the `QUERY.XML` file contains **complementary queries** (with different IDs), this field must be set to the highest verbosity level among them. If the file contains **alternative coverage queries** (with the same ID), this field must list the verbosity levels of each option in order of declaration, separated by commas. You can read more about complementary and coverage queries in [Complementarity and Coverage Queries](#complementarity-and-coverage-queries) 	| `High`, `Low, Medium` 	|
| `Requirements` 	| List software or applications needed for the query to request events successfully. 	| `Windows Sysmon` 	|
| `Tag` 	| Multi-key taxonomy for advanced categorization. Read the section [Tag Structure](#tag-structure) to use this field effectively. 	| `Technique/T1234`, `Category/Object Access` 	|
| `RequiresAudit` 	| Indicates if this query needs additional auditing enabled. [Upcoming feature] 	| - 	|
| `RequiredSettings` 	| Lists audit policy or configuration settings needed for full effectiveness. [Upcoming feature] 	| - 	|
| `Description` 	| Free text summary of the query purpose and scope. 	| - 	|

[^1]: We suggest keeping the `Intent.Secondary` field as short as possible.

## Intent recommendations

Microsoft Windows follows a standard audit policy of categories and subcategories (as found in `auditpol`). The following table showcases a clear one-to-one mapping between the field `Intent.Primary` categories and Microsoft’s audit categories and subcategories.

| Microsoft Category (Secondary) 	| Intent.Primary 	| Notes & examples 	|
|:---:	|:---:	|:---:	|
| Account Logon 	| Identity and Access 	| Kerberos, credential validation 	|
| Account Management 	| Identity and Access 	| user & group mgmt 	|
| Logon/Logoff 	| Identity and Access 	| session tracking, VPN, IPSec 	|
| DS Access 	| Identity and Access 	| Directory Services 	|
| Privilege Use 	| Identity and Access 	| privilege elevation 	|
| Policy Change 	| Security and Auditing 	| audit policies, authz policies 	|
| Object Access 	| Security and Auditing 	| file shares, registry, storage 	|
| Detailed Tracking 	| Security and Auditing 	| process creation, DPAPI, RPC 	|
| Global Object Access Auditing 	| Security and Auditing 	| sweeping resource access 	|
| System 	| System 	| IPsec driver, system integrity, state changes 	|
| - 	| Application and Services 	| Reserved for SQL server applications or any provider outside of the security-centric categories 	|
| - 	| Network 	| Reserved for IIS, DNS, DHCP, Firewall or external systems that generate network-related logs 	|

* Depending on the needs of your organization, you may want to tweek the suggested assignments.

## Author and Reference structure

Defines the origin and credibility of the query.

| Subfield   | Description                                                                                           |
| ---------- | ----------------------------------------------------------------------------------------------------- |
| `Name`     | Full name of the author or referenced author.                                                         |
| `Alias`    | Short handle, username, or alias (e.g., GitHub handle).                                               |
| `Resource` | One or more repositories, documentation links, or URLs.                                               |

For the `Resource` field, you must specify the type of resource using the value format `Type/Value`. Currently allowed types are:

| Key           | Purpose                                                                                                           |
| ------------- | ------------------------------------------------------- |
| `Github`      | Name of the GitHub repository.                          |
| `URL`         | URL to the online resource.                             |
| `Misc`        | Other resources.                                        |

```diff
+ Please, never forget to acknowledge the work of other people!
```

## Tag Structure

Tags use Key/Value pairs to provide semantic categorization of each query. This enables precise filtering, automated alert prioritization, and consistent documentation.

You can declare multiple values for the same key (e.g. `Technique/T1558, T1110`) to indicate that the query applies to several related items. Keep in mind that the `Criticality` field should have only one value.

| Key 	| Purpose 	| Example value 	|
|---	|---	|---	|
| `Technique` 	| Maps to MITRE ATT&CK techniques or subtechniques, supporting standardized threat modeling. 	| `Technique/T1558, T1110` 	|
| `Category` 	| Aligns with Microsoft's high-level audit policy categories, indicating broad areas of system activity[^2]. 	| `Category/Resource Access` 	|
| `Subcategory` 	| Maps to Microsoft's detailed audit policy subcategories, providing granular context[^2]. 	| `Subcategory/File Share` 	|
| `Action` 	| Describes the specific monitored behavior or operation, often reflecting a verb-like activity (e.g. "File Sharing"), a well-known adversary tactic (e.g. "Kerberoasting"), or a generic security operation (e.g. "Authentication"). 	| `Action/File Sharing`, `Action/Kerberoasting` 	|
| `Criticality` 	| Indicates the expected impact level of the detection using the supported values `Low`, `Medium`, or `High`. 	| `Criticality/Medium` 	|
| `Source` 	| Indicates the source of the event. 	| `Source/Sysmon`, `Source/Windows Events` 	|
| `Misc` 	| Used for additional context such as protocols, infrastructure elements, or environment specifics. 	| `Misc/SMB, ADDS` 	|

[^2]: Run `auditpol /get /category:*` to see all categories and subcategories.

## RequiresAudit and AuditSettings fields

```diff
- Future implementation for security automation.
```

The `RequiresAudit` and `RequiredSettings` fields will allow the user to decide if they want to enable required settings and configure them automatically. 

Under `RequiredSettings`, the allowed fields are `GroupPolicy` for Group Policy related settings, `AuditPolicy` for Audit Policy related settings, and `Registry` for Registry related settings.


## The Query Event (Sub)Metadata Schema (EVT)

The EVT schema is another section of the metadata that you **MUST** include in a `QUERY.XML` file. The Event Metadata provides granular information of each event in the query, including the event ids, channel per event, description of the event, and event types (Success and/or Failure).

```XML
<!--
    MetaSchemaVersion:  EVT-1.0
    4624 - Security:    An account was successfully logged on (S, F)
    1 - Sysmon:         Process creation (-)
-->
```

```diff
- Currently, the EVT Schema is not in use, but it will be necessary for the future implementation of RequiresAudit and AuditSettings fields. Nonetheless, to ensure consistency and well documented queries, scripts under this repository will enforce that each event in each Select or Suppress element is properly commented in the EVT schema.
```

### Comment blocks

You can include comment blocks above any Select or Suppress element. Comment blocks provide information about the events or query logic. Below in an example:

```XML
<!-- Comment: 
    [!] Module Logging (4103) logs every parameter passed to any module: Confidentiality and credential leaking risk.
    [!] ScriptBlock Logging (4104) is highly verbose and can fill log files if not handled appropiately. 
    [!] ScriptBlock Logging will not log sensitive parameters as long as they are not included in the scripts.
    [!] (4105) and (4106) are highly verbose events but they can corelate the precise moments when a script started and ended.
-->
<Select Path="Microsoft-Windows-PowerShell/Operational">
    *[System[(EventID=4103 or EventID=4104 or EventID=4105 or EventID=4106)]]
</Select>
```

Comment blocks follow a very flexible and easy syntax. This syntax is important so that the comments can be processed correctly by the scripts in this repository.

1. A comment block starts with `<!-- Comment:` (in one line).
2. At the begginning of each comment, you **MUST** add the type of the comment. `[!]` is for important messages, and `[*]` for general comments. The 'importance' or severity of a message is subjective. Comments are also one-liners. There is no limit in length, but it is recommended to keep the commentaries as short as possible.
3. Close the comment block in the next line.

## Complementarity and Coverage Queries

A `QUERY.XML` file may contain multiple `<Query>` elements.

- **Same `Id` property**: Signals alternative verbosity levels or scoping options (coverage). The user (or automation) can select which variant to import. The [`Verbosity`](#fields) field in the metadata schema is used to identify the verbosity level of each query.
- **Different `Id` property**: Treated as complementary detection components that are imported together under the same metadata intent.

The `Id` property in the `QUERY.XML` file do not represent the actual `Id`s of the queries in the final `<QueryList>` element. These are used during the preprocessing step before the import. You can safely type any number; however, it is highly recommended to start the `Id`s from the value 0. Repeat the same `Id` if you want to create a **coverage queries**, or use different `Id`s is you want to create **complementary queries**.

### Cheatsheet

Use complementary queries (different IDs) when:

- Each `<Query>` in the `QUERY.XML` file covers a distinct but complementary aspect of the same security concern.
- You intend to always import both queries when pulling the `QUERY.XML`.

On the otherhand, use coverage queries (same IDs) when:

- There are different granularities of the same detection concept or intent.
- The user (or tool) will select only one variant to import, based on performance or coverage needs.

Additionally, keep in mind that using complementary queries (different IDs) still allows you to adjust the coverage as needed by simply disabling or removing any query ID that is not required.