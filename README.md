# Private Azure ML deployment

## Project Status

This project provides scripts for a simple deployment of a privately enclosed Azure Machine Learning environment, with all the required services pre-connected. Normally this deployment process is time consuming, as it requires a setup of a wide range of Azure services. Here we utilize one Terraform script, with minimum set of parameters, that can be invoked either directly or via bash script.

While the scripts provided in this repository will get you a quick-start with secure AML environment, for a full production scale Trusted Research Environment you should consider using the [AzureTRE](https://github.com/microsoft/AzureTRE/), that this repository is a spin-off. AzureTRE is a solution accelerator aiming to be a great starting point for a customized Trusted Research Environment, allowing users to customize and deploy fully isolated research environments, one type being AzureML.

This project does not have a dedicated team of maintainers but relies on you and the community to maintain and enhance the solution. No guarantees can be offered as to response times on issues, feature requests, or to the long term road map for the project.

It is important before deployment of the solution that the [Support Policy](SUPPORT.md) is read and understood.

## Getting started

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
1. Once the resources are deployed you can either fetch username and password for the jumpbox either from Key Vault or you can take raw output from terraform:

    ```terraform output -raw```
1. Connect to jumpbox by navigating to Azure portal, select the VM created, press Connect and choose Bastion. Enter the user name and password from the previous step.
1. From the jumpbox you are now able to access all of the resources residing on private network (e.g. ml.azure.com)

## Background

While AzureML can be easily deployed with a few clicks as a quick public research platform, the default setup doesn't meet the security needs of many organizations. Things like controlled data ingestion, network isolation and prevention of exfiltration of sensitive data are left to the system admins to configure.

Since this is a rather common scenario, and the task of creating a secure ML environment is time consuming, we saw a need for a script style accelerator that can be easily customized and reused.

## Support

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

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
