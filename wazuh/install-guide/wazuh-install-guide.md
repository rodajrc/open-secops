# Wazuh Installation Guide (Distributed, Assisted)

## Installation Order

1. Indexer
2. Server
3. Dashboard

## Assisted Installation

[Installing the Wazuh indexer using the assisted installation method](https://documentation.wazuh.com/current/installation-guide/wazuh-indexer/installation-assistant.html)
### Indexer Installation
#### Download the installation assistant files

Run every command in this guide from the home directory (`cd ~`). The installation assistant also expects `wazuh-install-files.tar` in that directory.

Download the installation assistant and the configuration template.

```bash
curl -sO https://packages.wazuh.com/4.13/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.13/config.yml
```
#### Modify `config.yml`

In the configuration file, replace the node names and IP addresses for each Wazuh server, Wazuh indexer, and Wazuh dashboard accordingly.

For a simple 3-node setup you can use the configuration below. The node names must match the `NODE_NAME` values used later in this guide.

```yml
nodes:
  # Wazuh indexer nodes
  indexer:
    - name: wazuh-srv01
      ip: "0.0.0.1"

  # Wazuh server nodes
  server:
    - name: wazuh-srv02
      ip: "0.0.0.2"
    #  node_type: master
    #- name: wazuh-srv04
    #  ip: "0.0.0.3"
    #  node_type: worker

  # Wazuh dashboard nodes
  dashboard:
    - name: wazuh-srv03
      ip: "0.0.0.4"
```

> [!NOTE]
> You might want to have the Linux boxes already installed with its corresponding static IP addresses assigned. As a recommendation, keep track of each of your Wazuh-cluster nodes in a spreadsheet.

> [!WARNING]
> If you mistakenly assign an incorrect IP address or name to a particular node, you will need to start over again the whole process!

Run the following command to generate the `wazuh-install-files.tar` compressed file, which will contain all necessary information during the installation process.

```bash
chmod +x wazuh-install.sh
bash wazuh-install.sh --generate-config-files
```

You will need to copy generated config files to all servers of the distributed deployment (Wazuh Server, Wazuh Indexer, and Wazuh Dashboard).

> [!NOTE]
> For a quick, terminal-only solution to this task, you can use `scp`. Alternatively, you can use _MobaXterm_ to download the file using the GUI.

> [!WARNING]
> You might need to change the ownership and permissions of the configurations file to allow `scp` download it.
#### Install the Wazuh Indexer Node

Using the `wazuh-install.sh` script, run the command again with the following parameter `--wazuh-indexer` and the node name. You might need to download again the file if this is another indexer node in the cluster.

```bash
# Download wazuh-install.sh
curl -sO https://packages.wazuh.com/4.13/wazuh-install.sh

NODE_NAME=wazuh-srv01  # ADJUST
bash wazuh-install.sh --wazuh-indexer $NODE_NAME
```
#### Initialize the Indexer Cluster

Regardless if it is one or many indexer, run the Wazuh installation assistant with option `--start-cluster` on any Wazuh indexer node to load the new certificates information and start the cluster.

> [!WARNING]
> Make sure you have a copy of the `wazuh-install-files.tar` in the working directory.

```bash
bash wazuh-install.sh --start-cluster
```
#### Verify Installation

First, extract the `wazuh-install-files.tar` and get the _admin_ password using the following command.

```bash
tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O | grep -P "\'admin\'" -A 1
```

Then, run the following command to confirm that the installation was successful.

```bash
HOST_IP="0.0.0.0"   # ADJUST
curl -k -u admin https://$HOST_IP:9200   # Confirm the installation
curl -k -u admin https://$HOST_IP:9200/_cat/nodes?v   # check cluster nodes
```

The curl requests will prompt for a password for the user _admin_. Use the password obtained in the first step.
#### Disable Wazuh Updates

> [!WARNING]
> It is advised to disable the Wazuh Package Repository to prevent accidental upgrades that could break the environment.

For _APT_, you can use the following commands.

```bash
sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
apt update
```

> [!NOTE]
> This process should be repeated in every Wazuh node. The warning message won't appear any more.
### Server Installation

> [!WARNING]
> Do not forget to add the `wazuh-install-files.tar` in the working directory (often `~/`).

Download the Wazuh installation script using the following command.

```bash
curl -sO https://packages.wazuh.com/4.13/wazuh-install.sh
```

Add temporarily an environment variable with the name of the node that you assigned in the `config.yml` during the Indexer installation. Then run the installation script with the `--wazuh-server` parameter.

```bash
NODE_NAME=wazuh-srv02   # ADJUST
bash wazuh-install.sh --wazuh-server $NODE_NAME
```

> [!NOTE]
> If you want a multi-node cluster of Wazuh Server instances, repeat the process in all your Wazuh Manager server nodes.
#### Disable Wazuh Updates

```bash
sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
apt update
```
### Dashboard Installation

> [!WARNING]
> Do not forget to add the `wazuh-install-files.tar` in the working directory (often `~/`).

Download the Wazuh installation script using the following command.

```bash
curl -sO https://packages.wazuh.com/4.13/wazuh-install.sh
```

Add temporarily an environment variable with the name of the node that you assigned in the `config.yml` during the Indexer installation. Then run the installation script with the `--wazuh-dashboard` parameter.

```bash
NODE_NAME=wazuh-srv03   # ADJUST
bash wazuh-install.sh --wazuh-dashboard $NODE_NAME
```

> [!NOTE]
> You can change the default web user interface port using the optional parameter `-p <PORT_NUMBER>`. The default port is 443.

If everything went fine, you should get an output like this:

```bash
05/10/2025 19:05:54 INFO: --- Summary ---
05/10/2025 19:05:54 INFO: You can access the web interface https://<DASHBOARD_IP>:443
    User: admin
    Password: <ADMIN_PASSWORD>
05/10/2025 19:05:54 INFO: Installation finished.
```
#### Disable Wazuh Updates

```bash
sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
apt update
```

