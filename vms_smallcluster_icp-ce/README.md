# Deploying a Small ICP Kubernetes cluster

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


## Scale workers
To increase the number of workers, simply *increase* the number in [worker-nodes](variables.tf#L53) and apply the update configuration

`terraform apply`

To decrease the number of workers, simply *decrease* the number in [worker-nodes](variables.tf#L53) and apply the update configuration

Please note; because of how terraform handles module dependencies and triggers, it is currently necessary to retrigger the scaling resource **after scaling down** nodes.
If you don't do this ICP will continue to report inactive nodes until the next scaling event.
To scale down, then manually trigger the removal of deleted node, run these commands:

1. Apply config to reduce the number of worker VMs
    
    `terraform apply` 
    
2. Taint the scaling resource to force a recreation

    `terraform taint --module icpprovision null_resource.icp-worker-scaler` 

3. Apply the configuration to force recreation of the scaling resource, removing the deleted nodes from kubernetes

    `terraform apply`

