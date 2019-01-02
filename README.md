<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvijayshinva%2FAzureWireGuard%2Fmaster%2FAzureWireGuard%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fvijayshinva%2FAzureWireGuard%2Fmaster%2FAzureWireGuard%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# AzureWireGuard - Azure ARM Template
The quickest way to setup your own modern VPN server. 

[WireGuard][wireguard] VPN is a rethink of how VPN software are designed and is receiving genuine appreciation from the community. This [Azure ARM template][azure-arm] helps you to setup a WireGuard VPN server quickly, taking care of all the configuration steps. 

# What does this Azure ARM template do ?
- Create an [Ubuntu Server][ubuntu] Virtual Machine.
    - The only inputs you provide are the administrator username and password.
    - The name of all resources are generated automatically to avoid any conflicts.
- An Azure Network Security Group with firewall rules is attached to the Virtual Machine.
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
Some knowledge of how [Azure ARM templates][azure-arm] work is really helpful.
## Method 1 - From [Visual Studio][vs]
- Clone the [git repository][git-repo].
- Open the solution file in Visual Studio and deploy from Visual Studio.

## Method 2 - From [Azure Deploy][azure-deploy]
- Hit the [Deploy to Azure][azure-deploy-awg] button at the top. 

## Other Methods
- There are multiple ways to deploy an Azure ARM template like  [Powershell][azure-ps], [Azure CLI][azure-cli], [Azure Portal][azure-portal] and [REST API][azure-rest].

# How to download WireGuard Client Configuration files ?
- The client configuration files are named wg0-client-1.conf, wg0-client-2.conf, ..., wg0-client-9.conf and wg0-client-10.conf.
- They are located in the administrator users home folder (~/).
- You can use tools like scp and pscp to download the client configuration files directly from the server.
    
    scp &lt;admin-user&gt;@&lt;server-fqdn&gt;:/home/&lt;admin-user&gt;/wg0-client-1.conf /local/dir/
    
    pscp &lt;admin-user&gt;@&lt;server-fqdn&gt;:/home/&lt;admin-user&gt;/wg0-client-1.conf c:\local\

    Example: 

	scp vmadmin@awgyj5lzwixbj3ng.westus.cloudapp.azure.com:/home/vmadmin/wg0-client* /local/dir/

# Windows Clients
- The client configuration files generated have Linux Line Endings (LF) while Windows WireGuard clients would expect DOS Line Endings (CRLF).

# General Recommendations
- Recommended to have a separate [Azure Resource Group][azure-rg] for this deployment so that when you want to destroy the setup you can easily delete the Azure Resource Group and all the associated Azure resources are removed.
- Recommended to have a VM with atleast two cores.
- Once the configuration files are downloaded, you can disable the SSH port 22 on the Azure Network Security Group for added security.
- [Azure Accelerated Networking][azure-accelerated-nw] is enabled by default for better network performance, this limits the choice of Azure VM sizes.

[azure-arm]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/
[wireguard]: https://www.wireguard.com/
[dns]: https://1.1.1.1/
[ubuntu]: https://www.ubuntu.com/server
[azure-portal]: https://portal.azure.com
[vs]: https://visualstudio.microsoft.com/vs/community/
[git-repo]: https://github.com/vijayshinva/AzureWireGuard
[azure-ps]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy
[azure-cli]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli
[azure-rest]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-rest
[azure-deploy]: azuredeploy.net
[azure-portal]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-portal
[azure-deploy-awg]: https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvijayshinva%2FAzureWireGuard%2Fmaster%2FAzureWireGuard%2FLinuxVirtualMachine.json
[azure-rg]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-groups
[ufw]: https://help.ubuntu.com/community/UFW
[azure-accelerated-nw]: https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli