##### SoftLayer Access Credentials ######
variable "sl_username" { default = "__INSERT_YOUR_OWN__" }
variable "sl_api_key" { default = "__INSERT_YOUR_OWN__" }

variable "key_name" { 
  description = "Name or reference of SSH key to provision softlayer instances with"
  default = "patro-key"
}


##### Common VM specifications ######
variable "datacenter" { default = "sao01" }
variable "domain" { default = "icp2.patro" }

##### ICP version #####
variable "icp_version" { default = "ibmcom/icp-inception:latest" }

# Name of the ICP installation, will be used as basename for VMs
variable "instance_name" { default = "sao" }

variable "icp_admin_password" {
  description = "ICP Admin Users password password. 'Generate' generates a new random password"
  default     = "Generate"
}
##### ICP Instance details ######
variable "master" {
  type = "map"
  
  default = {
    nodes       = "1"
    cpu_cores   = "2"
    disk_size   = "100" // GB
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
    nodes       = "1"
    cpu_cores   = "8"
    disk_size   = "100" // GB
    local_disk  = true
    memory      = "16384"
    network_speed= "1000"
    private_network_only=false
    hourly_billing=true
  }
 
}
