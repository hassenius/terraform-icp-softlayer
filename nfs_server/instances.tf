provider "softlayer" {
#    username = "${var.sl_username}"
#    api_key = "${var.sl_api_key}"
}

data "softlayer_ssh_key" "public_key" {
  label = "${var.key_name}"
}

resource "softlayer_virtual_guest" "nfs" {
    count       = "${var.nfs["nodes"]}"
    
    datacenter  = "${var.datacenter}"
    domain      = "${var.domain}"
    hostname    = "${format("${lower(var.instance_name)}-%01d", count.index + 1) }"
    
    os_reference_code = "UBUNTU_16_64"

    cores       = "${var.nfs["cpu_cores"]}"
    memory      = "${var.nfs["memory"]}"
    disks       = ["${var.nfs["disk_size"]}"]
    local_disk  = "${var.nfs["local_disk"]}"
    network_speed         = "${var.nfs["network_speed"]}"
    hourly_billing        = "${var.nfs["hourly_billing"]}"
    private_network_only  = "${var.nfs["private_network_only"]}"

    user_metadata = "{\"value\":\"newvalue\"}"

    ssh_key_ids = ["${data.softlayer_ssh_key.public_key.id}"]
}

module "provision" {
    source = "github.com/patrocinio/terraform-module-nfs-server-deploy"
    
    nfs = ["${softlayer_virtual_guest.nfs.ipv4_address}"]
    
    /* Workaround for terraform issue #10857
     When this is fixed, we can work this out autmatically */

    cluster_size  = "${var.nfs["nodes"]}"

    # SSH user and key for terraform to connect to newly created SoftLayer resources
    # ssh_key is the private key corresponding to the public keyname specified in var.key_name
    ssh_user  = "root"
    ssh_key   = "~/.ssh/id_rsa"
    
} 

