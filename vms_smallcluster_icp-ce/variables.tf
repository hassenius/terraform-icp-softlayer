##### SoftLayer Access Credentials ######
variable "sl_username" { default = "__INSERT_YOUR_OWN__" }
variable "sl_api_key" { default = "__INSERT_YOUR_OWN__" }

variable "key_name" { 
  description = "Name or reference of SSH key to provision softlayer instances with"
  default = "patro-key"
}


##### Common VM specifications ######
variable "datacenter" { default = "wdc01" }
variable "domain" { default = "icp2.camse" }

##### ICP version #####
variable "icp_version" { default = "ibmcom/icp-inception:2.1.0-beta-3" }

# Name of the ICP installation, will be used as basename for VMs
variable "instance_name" { default = "myicp" }

##### ICP Instance details ######
variable "master" {
  type = "map"
  
  default = {
    nodes       = "1"
    cpu_cores   = "2"
    disk_size   = "25" // GB
    local_disk  = false
    memory      = "8192"
    network_speed= "1000"
    private_network_only=false
    hourly_billing=true
  }
 
}
variable "proxy" {
  type = "map"
  
  default = {
    nodes       = "1"
    cpu_cores   = "2"
    disk_size   = "25" // GB
    local_disk  = true
    memory      = "8192"
    network_speed= "1000"
    private_network_only=false
    hourly_billing=true
  }
 
}
variable "worker" {
  type = "map"
  
  default = {
    nodes       = "2"
    cpu_cores   = "2"
    disk_size   = "25" // GB
    local_disk  = true
    memory      = "8192"
    network_speed= "1000"
    private_network_only=false
    hourly_billing=true
  }
 
}
