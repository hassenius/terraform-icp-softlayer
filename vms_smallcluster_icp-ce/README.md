# vms_smallcluster_icp-ce

Example deploying a small ICP cluster of 1 master, 1 proxy and 2 workers on SoftLayer VMs

To start, examine [variables.tf](variables.tf).
At a minimum you will need to 
* Insert the SSH key name to use for provisioning in the [ssh_key field](variables.tf#L7)
* Provide a SoftLayer username and API Key by either
   - inserting into [sl_username and sl_api_key variable](variables.tf#L2)
   - Replacing the [softlayer provider section](instances.tf#L1) with `provider "softlayer" {}` and providing SL_USERNAME and SL_API_KEY in environment variables
  More information on [softlayer github](https://github.com/softlayer/terraform-provider-softlayer/blob/master/docs/provider.md)
  

Then run

1. `terraform init`
2. `terraform get`
3. `terraform apply`
