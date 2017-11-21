##### SoftLayer Access Credentials ######
variable "sl_username" { default = "__INSERT_YOUR_OWN__" }
variable "sl_api_key" { default = "__INSERT_YOUR_OWN__" }

variable "key_name" { 
  description = "Name or reference of SSH key to provision softlayer instances with"
  default = "__INSERT_YOUR_OWN__"
}

##### Common VM specifications ######
variable "datacenter" { default = "lon06" }
variable "domain" { default = "ibmcloud.private" }

# Name of the ICP installation, will be used as basename for VMs
variable "instance_name" { default = "myicp" }

#### glusterfs cluster details #####
variable "gluster" {
  type = "map"
  
  default = {
    nodes       = "3"
    cpu_cores   = "4"
    root_disk_size   = "100" // GB
    #storage_disk_size = "100"
    local_disk  = true
    memory      = "8192"
    network_speed= "1000"
    private_network_only=false
    hourly_billing=true
  }
 
}

##### ICP Instance details ######
variable "master" {
  type = "map"
  
  default = {
    nodes       = "3"
    cpu_cores   = "8"
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
    nodes       = "3"
    cpu_cores   = "8"
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
    cpu_cores   = "8"
    disk_size   = "25" // GB
    local_disk  = true
    memory      = "8192"
    network_speed= "1000"
    private_network_only=false
    hourly_billing=true
  }
 
}
