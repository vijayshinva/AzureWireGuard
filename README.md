# AzureWireGuard - Azure Bicep Template
The quickest way to setup your own modern VPN server. 

[WireGuard][wireguard] VPN is a rethink of how VPN software are designed and is receiving genuine appreciation from the community. This [Azure Bicep template][azure-bicep] helps you to setup a WireGuard VPN server quickly, taking care of all the configuration steps. 

# What does this Azure Bicep template do ?
- Create an [Azure Resource Group][azure-rg]. The name of all resources are generated automatically to avoid any conflicts.
- Create an [Ubuntu Server][ubuntu] Virtual Machine.
    - You will be prompted for a password during the setup. The default admin name is `vmadmin`
- A [Network Security Group][azure-nsg] with firewall rules is attached to the Virtual Machine.
    - Port 51820 is enabled for WireGuard
    - Port 22 is enabled for SSH. Disable this port once you download the config files and enable it only for maintenance.
- Install WireGuard Server.
- Configure WireGuard Server
    - Create Private and Public Keys for Server and Client.
    - Create the Server Configuration.
    - The WireGuard interface IP address is set to 10.13.13.1.
- Setup NAT on the server to forward client traffic to the internet.
- Start the WireGuard Interface.
- Configure WireGuard to auto start.
- Generate ten client configuration files, which you can download and start using. 
    - The ten clients are given the IP addresses 10.13.13.101 to 10.13.13.110.
    - The Client DNS server is set to [1.1.1.1][dns].
- Enable [UFW][ufw] firewall.
- Install Ubuntu Server Upgrades.
- Schedule a Reboot after 24 hours, to ensure all Ubuntu Server Upgrades are applied.

# How to deploy ?

Some knowledge of how [Azure Bicep templates][azure-bicep] work is really helpful.

## Method 1 - From [Azure CLI][azure-bicep-cli]
- Clone the [git repository][git-repo].
- Login to your Azure subscription

    `az login`
- (Optional Step ... In case you have multiple Azure subscriptions) List your Azure subscriptions

    `az account list --output table`
- (Optional Step ... In case you have multiple Azure subscriptions) Set your default Azure subscription to which this Bicep template will be deployed

    `az account set --subscription <SubscriptionId>`
- (Optional Step ... In case you want to validate the template) Run a [what-if][azure-bicep-whatif] check 

    `az deployment sub create --name wireguard --location eastus --template-file .\AzureWireGuard\AzureWireGuard.bicep --what-if`
- Deploy the Bicep template with defaults. For customization refer to [this](#customizing-the-deployment).

    `az deployment sub create --name wireguard --location eastus --template-file .\AzureWireGuard\AzureWireGuard.bicep`

## Other Methods
- There are multiple ways to deploy an Azure Bicep template like  [Powershell][azure-bicep-ps], [VS Code][azure-bicep-vscode] and [Azure Portal Cloud Shell][azure-bicep-cs].

# Customizing the deployment
- While deploying the Bicep template you can pass a parameters file

    `az deployment sub create --name wireguard --location eastus --template-file .\AzureWireGuard\AzureWireGuard.bicep --parameters "@AzureWireGuard\AzureWireGuard.parameters.json"`

- The template parameters available for customization are

| Parameter | Description | Defaults |
| --------- | ----------- | -------- |
| code          | A string used in the resource  names | Random string to avoid resource conflicts. `uniqueString` Based on the Subscription Id and Location |
| adminUsername | Admin Username for the Virtual Machine | vmadmin |
| adminPassword | Password for the Virtual Machine | Prompts during deployment |
| location      | Location to deploy the resources. The location specified in the `az deployment` command does not control the location of the resources. It is the location of the Azure Deployment | eastus |
| vmSize        | Size of the Virtual Machine | Standard_DS2_v2 |
| tags          | Tags that are attached to the resources created | DeployedOn |

# How to download WireGuard Client Configuration files ?
- The client configuration files are named wg0-client-1.conf, wg0-client-2.conf, ..., wg0-client-9.conf and wg0-client-10.conf.
- They are located in the administrator users home folder (~/).
- You can use tools like scp and pscp to download the client configuration files directly from the server.
    
    `scp &lt;admin-user&gt;@&lt;server-fqdn&gt;:/home/&lt;admin-user&gt;/wg0-client-1.conf /local/dir/`
    
    `pscp &lt;admin-user&gt;@&lt;server-fqdn&gt;:/home/&lt;admin-user&gt;/wg0-client-1.conf c:\local\`

    Example: 

	`scp vmadmin@awgyj5lzwixbj3ng.westus.cloudapp.azure.com:/home/vmadmin/wg0-client* /local/dir/`

# Windows Clients
- The client configuration files generated have Linux Line Endings (LF) while Windows WireGuard clients would expect DOS Line Endings (CRLF).

# General Recommendations
- Recommended to have a VM with atleast two cores.
- Once the configuration files are downloaded, you can disable the SSH port 22 on the Azure Network Security Group for added security.
- [Azure Accelerated Networking][azure-accelerated-nw] is enabled by default for better network performance, this limits the choice of Azure VM sizes.

# Azure ARM Version

The earlier version of AzureWireGuard used [Azure ARM templates][azure-arm]. It is no longer maintained but is available on the branch named [arm-retired][git-repo-retired]

# Contributing
- Fork the repo on [GitHub][git-repo]
- Clone the project to your own machine
- Commit changes to your own branch
- Push your work back up to your fork
- Submit a Pull Request so that changes can be reviewed and merged

NOTE: Be sure to pull the latest from "upstream" before making a pull request!

[azure-bicep]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep
[wireguard]: https://www.wireguard.com/
[dns]: https://1.1.1.1/
[ubuntu]: https://www.ubuntu.com/server
[azure-arm]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview
[git-repo]: https://github.com/vijayshinva/AzureWireGuard
[git-repo-retired]: https://github.com/vijayshinva/AzureWireGuard/tree/arm-retired
[azure-bicep-whatif]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if
[azure-bicep-ps]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-powershell
[azure-bicep-cli]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli
[azure-bicep-vscode]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-vscode
[azure-bicep-cs]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cloud-shell?tabs=azure-cli
[azure-rg]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
[ufw]: https://help.ubuntu.com/community/UFW
[azure-accelerated-nw]: https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-how-it-works
[azure-nsg]: https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
