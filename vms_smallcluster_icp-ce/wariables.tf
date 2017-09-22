##### SoftLayer Access Credentials ######
variable "sl_username" { default = "hans.moen.case" }
variable "sl_api_key" { default = "319f291f0cc96fa9a88b33fafa13cf51dd374eaef6ab4847ac442ec461396446" }

variable "key_name" { 
  description = "Name or reference of SSH key to provision softlayer instances with"
  default = "hk_key"
}


##### Common VM specifications ######
variable "datacenter" { default = "ams03" }
variable "domain" { default = "ibmcloud.private" }

# Name of the ICP installation, will be used as basename for VMs
variable "instance_name" { default = "myicp" }

##### ICP Instance details ######
variable "master" {
  type = "map"
  
  default = {
    nodes       = "1"
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
    nodes       = "1"
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

# Username and password for the initial admin user
variable "icpuser" { default = "admin" }
variable "icppassword" { default = "admin" }
