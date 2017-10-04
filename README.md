# Deploying IBM Cloud Platform on SoftLayer using TerraForm

These TerraForm example configurations uses the [SoftLayer Provider](https://github.com/softlayer/terraform-provider-softlayer) to provision servers in SoftLayer
and [TerraForm Module ICP Deploy](https://github.com/ibm-cloud-architecture/terraform-module-icp-deploy) to deploy [IBM Cloud Private](https://www.ibm.com/cloud-computing/products/ibm-cloud-private/) on them.


### Pre-requisits

* These examples use the SoftLayer Provider available from [Github](https://github.com/softlayer/terraform-provider-softlayer) rather than the older provider that currently ships with TerraForm.
  Follow the [Installation instructions on the SoftLayer Github Page](https://github.com/softlayer/terraform-provider-softlayer#install)
* You'll need a SoftLayer API key. If you don't already have them at hand, follow the [instructions on IBM KnowledgeLayer](https://knowledgelayer.softlayer.com/procedure/retrieve-your-api-key) to retrieve or generate them

### Examples
1. [Provision ICP Communicty Edition on a small VM cluster](vms_smallcluster_icp-ce/)
