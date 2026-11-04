# Wazuh Multi-Tenancy Demo

The strategy is to tag logs with a unique tenant identifier and then use Role-Based Access Control (RBAC) at both the data (OpenSearch) and application (Wazuh) layers to enforce isolation.
## Enable Multi-tenancy

> [!NOTE]
> For simplicity in this DEMO, I am writing the documentation assuming two customer tenants: _Tenant A_ for Customer A, and _Tenant B_ for Customer B.

Start by editing the `/etc/wazuh-dashboard/opensearch_dashboards.yml` configuration file.

```yml
# opensearch_dashboards.yml

# Set to true
opensearch_security.multitenancy.enabled: true

# Add this line
opensearch_security.multitenancy.tenants.preferred: ["Global", "Private"] 

# Optionally edit this line to set a default tenant
uiSettings.overrides.defaultRoute: /app/wz-home?security_tenant=global
```

> [!WARNING]
> It is not clear why this step is required. Further research is needed.
## Segregate Agents with Groups

To separate which agents belongs to who, create agent groups following the instructions.

1. In the **Wazuh Dashboard**, navigate to **Agent Management > Groups**.
2. Then, click **"Add new group"** and name it after your tenant (e.g., `tenant-customer_name).
3. Select the new group, go to its **Configuration** (`<group>/agent.conf`), and add a label. This label is the unique code you mentioned.

```xml
<agent_config>
  <labels>
    <label key="tenant_group">tenant-name</label>
    <label key="tenant_id">customer-uuid</label>
  </labels>
</agent_config>

<!-- Example for tenant-a agent.conf file -->
<agent_config>
  <labels>
    <label key="tenant_group">tenant-a</label>
    <label key="tenant_id">ac381612</label>
  </labels>
</agent_config>
```

The `tenant_id` label will be attached to every log event from agents in this group. The value of the label must be a unique identifier, like an _UUID_ (The value of `tenant_id` in the example above is not an _UUID_ because its too short).

> [!NOTE]
> Modifications to the `agent.conf` for a particular (tenant) group is appended to the `ossec.conf` configuration of the enrolled agent.

## Enroll Agents with Automatic Group Membership

Simply go to Wazuh agent enrollment page and copy the command in the system where you want to install the agent.

Make sure to select the appropriate group for the corresponding agent.

> [!WARNING]
> Automatic and secure agent self-enrollment is not documented yet. In the meantime, enroll agents manually and select the tenant group for each one.

## Create an Index to Support Multiple Tenants (Single-node)

In this part of the configuration, you will need to do some changes to the following files in the Wazuh Server:

### Configure the Wazuh Template

> [!WARNING]
> It is not clear if this file should be modified directly in the Wazuh Server component or instead you should download the [template from the Wazuh GitHub Repository](https://raw.githubusercontent.com/wazuh/wazuh/v4.13.1/extensions/elasticsearch/7.x/wazuh-template.json). This section documents the steps I followed to set up the single-indexer node to support multiple tenants, including officially and not officially documented steps .

**Officially documented**

Download the template with the following command.

```bash
sudo curl -so template.json https://raw.githubusercontent.com/wazuh/wazuh/v4.13.1/extensions/elasticsearch/7.x/wazuh-template.json
```

Add the custom pattern in the `index_patterns` property as shown below.

```yml
"index_patterns": [
    "wazuh-alerts-4.x-*",
    "wazuh-archives-4.x-*",
    "tenant-alerts-*"        # Custom index for tenants
],
```

Save the file and forward the changes to the indexer with the following commands.

```bash
INDEXER_USERNAME=<user>
INDEXER_PASSWORD=<pass>
INDEXER_IP_ADDRESS=<0.0.0.0>

curl -XPUT -k -u $INDEXER_USERNAME:$INDEXER_PASSWORD 'https://$INDEXER_IP_ADDRESS:9200/_template/wazuh' -H 'Content-Type: application/json' -d @template.json
```

> [!NOTE]
> You can obtain the `INDEXER_USERNAME` and `INDEXER_PASSWORD` with the following command: `tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O | grep -P "\'admin\'" -A 1`. You must run this command in your working directory where `wazuh-install-files.tar` is located.

Once you run the `curl` command, you should get a response like this.

```bash
{"acknowledged":true}
```

**Not Officially documented**

Although not documented, I also modified the file `/etc/filebeat/wazuh-template.json`. This file exists in the Wazuh Manager (Wazuh Server) node.

Follow the steps to ensure that, if this happens to be unnecessary, don't get into further trouble:

1. Backup `/etc/filebeat/wazuh-template.json` by running the following command

```bash
sudo cp /etc/filebeat/wazuh-template.json /etc/filebeat/wazuh-template.json.bak
```

2. Edit `/etc/filebeat/wazuh-template.json` in the same way as we did before.
### Configure the Filebeat Manifest

In the Wazuh Manager, open the file `/usr/share/filebeat/module/wazuh/alerts/manifest.yml` and change the default indexer with the new one.

```yml
module_version: 0.1

var:
  - name: paths
    default:
      - /var/ossec/logs/alerts/alerts.json
  - name: index_prefix
    default: tenant-alerts-    # EDITED

input: config/alerts.yml

ingest_pipeline: ingest/pipeline.json
```

### Add Filebeat Pipeline Preprocessors

Finally, open the file `/usr/share/filebeat/module/wazuh/alerts/ingest/pipeline.json` and add the preprocessors that will modify the `index_prefix` of each event. Below is an example.

```json
{
	"date_index_name": {
		"if": "ctx?.agent?.labels?.tenant_id == 'ac381612'",
		"field": "timestamp",
		"date_rounding": "d",
		"index_name_prefix":"{{fields.index_prefix}}b-",
		"index_name_format": "yyyy.MM.dd",
		"ignore_failure": false
	}
},
{
	"date_index_name": {
		"if": "ctx?.agent?.labels?.tenant_id == '48e8ff5c'",
		"field": "timestamp",
		"date_rounding": "d",
		"index_name_prefix":"{{fields.index_prefix}}a-",
		"index_name_format": "yyyy.MM.dd",
		"ignore_failure": false
	}
},
```

> [!WARNING]
> Depending on what you want to achieve, you might need to remove the default `date_index_name` preprocessor rule, or append the new preprocessor before or after the default one.

> [!NOTE]
> The value of the `tenant_id` label will depend on the _UUID_ or whichever identifier method you chose in the [Segregate Agents with Groups](#segregate-agents-with-groups) section.

You might want to refer to [Elasticsearch ingest pipelines documentation](https://www.elastic.co/docs/manage-data/ingest/transform-enrich/ingest-pipelines#ingest-prerequisites) to learn how to create more complex preprocessor rules.

### Save changes

To apply the changes, it is critical to run the following command.

```
sudo filebeat setup --pipelines --modules wazuh
```

> [!NOTE]
> The following commands are also needed; though, it is unknown how they actually have an effect to Wazuh. Further research is required.

```
# Restart Filebeat
systemctl restart filebeat

# Setup Filebeat index management
sudo filebeat setup --index-management

# Restart systemctl and Wazuh components
sudo systemctl daemon-reload
sudo systemctl restart wazuh-server
sudo systemctl restart wazuh-indexer
sudo systemctl restart wazuh-dashboard
```

### Create the Index Pattern in the Wazuh UI

Navigate to **Dashboard Management** > **Index Patterns** and select **Create index pattern**. Create the index pattern by typing the pattern `tenant-alerts-*` in the **Index pattern name** field. Then choose the `@timestamp` field as the primery field for use with the global time filter. Finally, create the index pattern.

![1 index patterns tenant alerts](./images/1_index_patterns_tenant_alerts.png)

Upon creation of the index pattern, new indexes should be created automatically. There are several ways to validate this.

1. Navigate to **Indexer Management > Index Management > Indexes** and locate your new indexes.

![2 generated indexes tenants](./images/2_generated_indexes_tenants.png)

> [!NOTE]
> It might be necessary to ingest logs first to generate the index file.

2. Another way is to navigate to **Indexer Management > Dev Tools** and run the following query.

```http
GET /_cat/indices/tenant-*?v   # Replace 'tenant' with your keyword

# Output (Truncated)

health status index                             uuid
green  open   tenant-alerts-b-2025.10.06        1Y7KMCmQS7We_ScnliOjTg
green  open   tenant-alerts-a-2025.10.06        LH_9ZakWTH-1Mng4Bh7Dng
```

3. Inspect the logs manually in the **Discovery** dashboard.

![3 discovery tenant index](./images/3_discovery_tenant_index.png)

> [!TIP]
> Congratulations! You have successfully tagged all data that is being ingested into Wazuh.
## Create Indexes to Support Multiple Tenants (Multi-node)

> [!WARNING]
> Not documented yet. However, this [Wazuh blog](https://wazuh.com/blog/wazuh-multi-site-implementation/) offers clear guidance to set up this architecture.
## Access Control Mechanisms for Multi-Tenancy

To create tenants, it is necessary to create the appropriate access control mechanisms in the indexer and server components of Wazuh.

### Unknown settings

> [!WARNING]
> The following settings didn't seem to have any effect in the access control mechanism configured earlier, yet they are officially documented. Further research is required.

changes in `/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml`:
- `ip.selector`: Set to `true`
- `ip.ignore`: Added entry `wazuh-alerts-*` 
### Indexer Users and Roles

First, open the file `/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml` and make sure that that `run_as` is set to `true`.

> [!NOTE]
> This setting simply enables role mapping.

Navigate to **Indexer Manager > Security > Internal Users** and create two user accounts.
1. Select **Create internal user**
2. Specify a username like `tenant-a-admin` and `tenant-b-admin`
3. Select a password for both users

Once the users are created, navigate to the **Roles** tab and select **Create role**.
1. For the cluster permission choose `cluster_composite_ops_ro`
2. For the first indexer permission, the **index** is `*`, with permission `read`.

> [!WARNING]
> Failing to add the index permission above will block the user account at the login process. However, the index permission above will allow the user to access all index patterns. Further research is required.

3. Select **Add another index permission**. Type `wazuh-*` for the index pattern. Then, in the **Field level security** section, select `Exclude` with pattern `*`.

> [!NOTE]
> The index permission above is a workaround to minimize the over permissive rule that was created before.

4. Select **Add another index permission**. Type `wazuh-monitoring-*` for the index pattern. Then, in the **Index permissions** section select `read`. Finally, in the **Document level security** section type the following:

```json
{
  "bool": {
    "must": {
      "match": {
        "tenant_group": "tenant-a"
      }
    }
  }
}
```

> [!NOTE]
> This setting ensures that the user can only see the Wazuh agents grouped in the `tenant-a`

5. Select **Add another index permission**. Type `tenant-alerts-*` for the index pattern. Then, in the **Index Permissions** select `read`. Finally, in the **Document level security** section, type the following entry:

```json
{
    "bool": {
      "must": [],
      "filter": [
        {
          "match_all": {}
        },
        {
          "match_phrase": {
            "agent.labels.tenant_id": "48e8ff5c"
          }
        }        
      ],
      "should": [],
      "must_not": []
    }
}
```

> [!NOTE]
> This setting ensures that the user can only see events tagged with the `tenant_id` label and the corresponding value.

You will need to repeat the steps for every tenant user.

### Wazuh Policies

Now navigate to **Server Management > Security > Policies**. Depending on your needs, you will need to create shared policies for the users of all tenants (like allowing tenant admins to enroll agents) and specific policies for the users of each tenant (like reading data of specific agents).

> [!NOTE]
> I will only document how to create the policies for one tenant user, but keep in mind that the process is the same for any tenant user.

#### Policy `tenant-a-agent-read`

1. Select **Create policy**
2. Choose a name like `tenant-a-agent-read`
3. The action is `agent:read`. Then click **Add**.
4. Choose the **Resource** `agent:group`. Type the **Resource identifier** `tenant-a`. Then click **Add**
5. Select the effect: `Allow`
6. Apply and create the policy

> [!NOTE]
> This policy allows to read the data of any agent (`agent:read`) which is grouped in `tenant-a` (`agent:group:tenant-a`).

#### Policy `tenant-a-group-read`

1. Select **Create policy**
2. Choose a name like `tenant-a-group-read`
3. The action is `group:read`. Then click **Add**.
4. Choose the **Resource** `group:id`. Type the **Resource identifier** `tenant-a`. Then click **Add**
5. Select the effect: `Allow`
6. Apply and create the policy

> [!NOTE]
> This policy allows to read the group (`group:read`) that is identified as `tenant-a` (`group:read:tenant-a`). Notice that the **ID** of a group is the name of the group.

#### Policy `tenant-any-agent-create`

1. Select **Create policy**
2. Choose a name like `tenant-any-agent-create`
3. The action is `agent:create`. Then click **Add**.
4. Choose the **Resource** `*:*`. Type the **Resource identifier** `*` (This special type of action is refered as **resourceless action)**. Then click **Add**
5. Select the effect: `Allow`
6. Apply and create the policy

> [!NOTE]
> This policy allows to create the agents (`agent:create`) without any restriction (`*:*:*`).

> [!WARNING]
> This policy might not be recommended in all scenarios. Moreover, there is no clear way to enable the **agent group** selection tab or a method to assign the agent group on behalf of the user. Further research is required.

### Wazuh Roles and Role Mapping

Finally, navigate to the **Roles** tab and create two roles:
1. `tenant-a-role`
2. `tenant-b-role`

Assign the corresponding policies to each role.

Once that's done, navigate to `Roles mapping` and create two mappings:
1. `tenant-a-mapping`
2. `tenant-b-mapping`

To each mapping, assign the recently created roles and the corresponding users that were created earlier in the section [Indexer Users and Roles](#indexer-users-and-roles)

> [!TIP]
> Congratulations! You have set up multi-tenancy with two tenant admin users. Try to login with each user and validate that `tenant-a-admin` can only see the events of the `tenant-a` group. The same applies for the `tenant-b-admin`.

## Additional References

[Wazuh Documentation - Multi-Tenancy](https://documentation.wazuh.com/current/user-manual/wazuh-dashboard/multi-tenancy.html)

https://www.youtube.com/watch?v=_5Eyf2Pla_0

https://medium.com/@kabalifahad/setting-up-and-configuring-multi-tenancy-with-single-node-opensearch-wazuh-docker-image-c1ba43b92fc6

https://www.scribd.com/document/863830254/Multi-Tenancy-in-Wazuh-SIEM

https://www.youtube.com/watch?v=tJLmJhNZSaE&pp=ygUZd2F6dWggZW5yb2xsIHdpdGggYXBpIGtleQ%3D%3D 
