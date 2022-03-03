# Private Azure ML deployment

## Project Status

There is a need across industries to enable researchers, analysts, and developers to work with sensitive data sets, while still leveraging benefits coming from the managed public cloud solutions. Setting up an environment that enforces a secure boundary around resources, prevents the exfiltration of sensitive data and enables information governance controls to be enforced, can be a time consuming task.

This project provides Infrastructure as Code scripts for a quick and easy deployment of such an environment, based around privately enclosed Azure Machine Learning, with all the required services pre-connected. Applying the Terraform script with default parameters, will configure a fully functioning private AML environment, that can then be either used as such or connected to internal network via VPN.

While the scripts provided in this repository will get you a quick-start with secure AML environment, for a full production scale Trusted Research Environment you should consider using the [AzureTRE](https://github.com/microsoft/AzureTRE/), that this repository is a spin-off. AzureTRE is a solution accelerator aiming to be a great starting point for a customized Trusted Research Environment, allowing users to customize and deploy fully isolated research environments, one type being AzureML.

This project does not have a dedicated team of maintainers but relies on you and the community to maintain and enhance the solution. No guarantees can be offered as to response times on issues, feature requests, or to the long term road map for the project.

It is important before deployment of the solution that the [Support Policy](SUPPORT.md) is read and understood.

## Architecture

![Architecture overview](/assets/privateaml_architecture.png)

## Getting started

Pre-requirements:

* [Azure CLI (az) installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started)
* [Git installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Commands in this guide are Linux commands, but you can use PowerShell as well, or any other command line tool.

To provision AML resources:

1. Clone this repository

    ```git clone https://github.com/microsoft/privateAML```
1. Switch to terraform directory:

    ```cd privateAML/terraform/```
1. Copy parameter template file terraform.tfvars.tmpl to terraform.tfvars:

    ```cp terraform.tfvars.tmpl terraform.tfvars```
1. Modify the parameters in terraform.tfvars and save the file (you can skip this step if you are OK with defaults):

    ```nano terraform.tfvars```

    | Parameter | Description |
    | --- | --- |
    | Name | A 4 character name you can give to the resources. It will be combined with 4 random numbers to make names globally unique. If you would like to adjust the naming pattern, just adjust [locals.tf](./terraform/locals.tf) file where final name is generated. Default is "test". |
    | Location | Azure region/location where resources should be deployed, e.g. westus, eastus, northeurope, etc. Default is "westeurope" |
    | VNET_address_space | A network IP range that will be used to create the VNET and subnets used by the service. Default is "10.1.0.0/22." |

1. Initialize terraform:

    ```terraform init```
1. Deploy resources:

    ```terraform apply -auto-approve```
1. Once the resources are deployed you can fetch user name and password for the Jumpbox (marked as sensitive so blocked from outputting after terraform apply) by taking json output from terraform:

    ```terraform output -json```

## Route option 1 - accessing the environment through Jumpbox

The Jumpbox provides an option for a single user to access the secure AML environment. This option is suitable for quick testing and proofs of concept. It is however not suitable for a multi-user deployment, and you should consider connecting the VNET to your on-premises network with VPN (see Route option 2 below).

1. Connect to the Jumpbox by navigating to Azure portal, select the VM created, press Connect and choose Bastion. Enter the user name and password retrieved from the previous step. From the Jumpbox you are able to access all of the resources residing on private network (e.g. ml.azure.com)
1. (Optional): If your organization requires device enrollment before accessing corporate resources (i.e. if you see an error "You can't get there from here." or "This device does not meet your organization's compliance requirements"), enroll the Jumpbox to Azure AD by following the steps in Edge: open Edge and click "Sign in to sync data", select "Work or school account", and then press OK on "Allow my organization to manage my device". It takes a few minutes for the policies to be applied, device scanned and confirmed as secure to access corporate resources. You will know that the process is complete, once you are able to access the [https://ml.azure.com](https://ml.azure.com).

## Route option 2 - accessing the environment over VPN connection

For a scalable, multi-user and a user-friendly secure connection to the provisioned AML resources, establish a VPN connection between your on-premises network and VNET that has been provisioned.

1. Follow the steps in this guide: [https://docs.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal](https://docs.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal) to create a Hub VNET, VPN Gateway and establish a connection to the on-premises network.
1. After completing steps above, peer the AML VNET (spoke) to the Hub VNET created in the previous step. To do this, from the Azure Portal, click on the AML VNET, select Peerings - Add then select the Hub VNET created in the previous step.
1. Test the connection from the on-premises, by opening your browser and navigating to [https://ml.azure.com](https://ml.azure.com)

## Using the environment

1. Navigate to the Azure ML at [https://ml.azure.com](https://ml.azure.com)
1. Select the ML workspace that was created (e.g. "ml-test-1234")
1. Switch to "Compute" tab and click on New to create a new Compute Instance.
1. Click on Advanced Settings and select the Virtual Network, Subnet, and enable "No public IP". Press Create to create the Compute Instance.
1. Switch over to "Compute clusters" tab, and click on New.
1. Click Next, enter the "Compute name" and then select the Virtual Network, Subnet, and enable "No public IP". Enable the "Assign a managed identity" option with "System assigned": this will allow compute cluster to connect to the ACR.
1. Once the compute instance is created, navigate to Notebooks and create a new training and runner notebooks. You can find the sample notebooks in the [./samples](./samples) folder.
1. Open the runner notebook and execute the cells.

## Background

While AzureML can be easily deployed with a few clicks as a quick public research platform, the default setup doesn't meet the security needs of many organizations. Things like controlled data ingestion, network isolation and prevention of exfiltration of sensitive data are left to the system admins to configure.

Since this is a rather common scenario, and the task of creating a secure ML environment is time consuming, we saw a need for a script style accelerator that can be easily customized and reused.

## Network isolation details

* All provisioned components have either a private IP or a private endpoint connection, and reside on same VNET
* All inbound traffic is blocked
* Outbound traffic is limited and only access to the following URLs are allowed:

    | URL | Reason |
    | --- | --- |
    | ml.azure.com | AML Portal |
    | viennaglobal.azurecr.io | Required by AML |
    | *openml.org | Required by AML |
    | enterpriseregistration.windows.net | Required for device enrollment to AAD |
    | 169.254.169.254 | Required for device enrollment to AAD |
    | login.microsoftonline.com | Required for device enrollment to AAD |
    | pas.windows.net | Required for device enrollment to AAD |
    | *manage-beta.microsoft.com | Required for device enrollment to AAD |
    | *manage.microsoft.com | Required for device enrollment to AAD |
    | login.windows.net | Required for device enrollment to AAD |
    | *.azureedge.net | Required for device enrollment to AAD |
    | go.microsoft.com | Required for device enrollment to AAD |
    | msft.sts.microsoft.com | Required for device enrollment to AAD |
    | *github.com | Access to github |
    | *githubassets.com | Access to github |
    | git-scm.com | Access to github |
    | *githubusercontent.com | Access to github |
    | *core.windows.net | Access to Azure External Storage |
    | aka.ms | Access to Microsoft short links |
    | *powershellgallery.com | Access to PowerShellGallery |
    | management.azure.com | Access to the Azure management plane |
    | graph.microsoft.com | Access to the Microsoft Graph |
    | graph.windows.net | Access to the Microsoft Graph |
    | aadcdn.msftauth.net | Required for Azure auth |

* A network security group is setup on Shared Subnet, with following security rules:

    | Direction | Action | Port | Source | Destination |
    | --- | --- | --- | --- | --- |
    | Inbound | Allow | 29877,29876 | BatchNodeManagement | VirtualNetwork |
    | Inbound | Allow | 44224 | Internet | VirtualNetwork |
    | Inbound | Allow | Any | AzureLoadBalancer | VirtualNetwork |
    | Inbound | Deny | Any | Any | Any |
    | Outbound | Allow | 445 | VirtualNetwork | Storage |
    | Outbound | Allow | Any | VirtualNetwork | Storage |
    | Outbound | Allow | Any | Any | Internet |

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreement](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
