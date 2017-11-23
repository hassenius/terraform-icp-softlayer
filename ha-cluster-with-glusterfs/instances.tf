
resource "softlayer_virtual_guest" "icpmaster" {
    count       = "${var.master["nodes"]}"
    
    datacenter  = "${var.datacenter}"
    domain      = "${var.domain}"
    hostname    = "${format("${lower(var.instance_name)}-master%01d", count.index + 1) }"
    
    os_reference_code = "UBUNTU_16_64"

    cores       = "${var.master["cpu_cores"]}"
    memory      = "${var.master["memory"]}"
    disks       = ["${var.master["disk_size"]}"]
    local_disk  = "${var.master["local_disk"]}"
    network_speed         = "${var.master["network_speed"]}"
    hourly_billing        = "${var.master["hourly_billing"]}"
    private_network_only  = "${var.master["private_network_only"]}"

    user_metadata = "{\"value\":\"newvalue\"}"

    ssh_key_ids = ["${data.softlayer_ssh_key.public_key.id}"]
    
    ## Master nodes need gluster to share icp docker registry and icp audit files   
    provisioner "file" {
      connection {
        private_key = "${file(var.ssh_key)}"
      }
      content = "${join("", formatlist("%s     %s\n", softlayer_virtual_guest.glustercluster.*.ipv4_address_private,softlayer_virtual_guest.glustercluster.*.hostname))}"
      destination = "/tmp/hosts.txt"
    }
    
    provisioner "remote-exec" {
      
      connection {
        private_key = "${file(var.ssh_key)}"
      }
    
      inline = [
        "cat /tmp/hosts.txt | sudo tee -a /etc/hosts",
        "sudo mkdir -p /var/lib/registry",
        "sudo mkdir -p /var/lib/icp/audit",
        "sudo apt-get update",
        "sudo apt-get install -y glusterfs-client",
        "echo \"${softlayer_virtual_guest.glustercluster.0.hostname}:/icpaudit /var/lib/icp/audit glusterfs  defaults,_netdev 0 0\" | sudo tee -a /etc/fstab",
        "echo \"${softlayer_virtual_guest.glustercluster.0.hostname}:/icpregistry /var/lib/registry glusterfs  defaults,_netdev 0 0\" | sudo tee -a /etc/fstab",
        "sudo mount /var/lib/registry",
        "sudo mount /var/lib/icp/audit"
        
      ]
    }
}

resource "softlayer_virtual_guest" "icpworker" {
    count       = "${var.worker["nodes"]}"

    datacenter  = "${var.datacenter}"
    domain      = "${var.domain}"
    hostname    = "${format("${lower(var.instance_name)}-worker%01d", count.index + 1) }"

    os_reference_code = "UBUNTU_16_64"
    
    cores       = "${var.worker["cpu_cores"]}"
    memory      = "${var.worker["memory"]}"
    disks       = ["${var.worker["disk_size"]}"]
    local_disk  = "${var.worker["local_disk"]}"
    network_speed         = "${var.worker["network_speed"]}"
    hourly_billing        = "${var.worker["hourly_billing"]}"
    private_network_only  = "${var.worker["private_network_only"]}"
    
    user_metadata = "{\"value\":\"newvalue\"}"
    
    ssh_key_ids = ["${data.softlayer_ssh_key.public_key.id}"]
}

resource "softlayer_virtual_guest" "icpproxy" {
    count       = "${var.proxy["nodes"]}"

    datacenter  = "${var.datacenter}"
    domain      = "${var.domain}"
    hostname    = "${format("${lower(var.instance_name)}-proxy%01d", count.index + 1) }"

    os_reference_code = "UBUNTU_16_64"
    
    cores       = "${var.proxy["cpu_cores"]}"
    memory      = "${var.proxy["memory"]}"
    disks       = ["${var.proxy["disk_size"]}"]
    local_disk  = "${var.proxy["local_disk"]}"
    network_speed         = "${var.proxy["network_speed"]}"
    hourly_billing        = "${var.proxy["hourly_billing"]}"
    private_network_only  = "${var.proxy["private_network_only"]}"
    
    user_metadata = "{\"value\":\"newvalue\"}"
    
    ssh_key_ids = ["${data.softlayer_ssh_key.public_key.id}"]
}



module "icpprovision" {
    #source = "icp-provision"
    source = "github.com/hassenius/terraform-module-icp-deploy.git?ref=image_from_nfs"
    icp-master = ["${softlayer_virtual_guest.icpmaster.*.ipv4_address}"]
    icp-worker = ["${softlayer_virtual_guest.icpworker.*.ipv4_address}"]
    icp-proxy = ["${softlayer_virtual_guest.icpproxy.*.ipv4_address}"]
    
    #icp-version = "2.1.0-beta-1"
    #icp-version = "1.2.0"
    icp-version = "ibmcom/icp-inception:2.1.0-ee"
    image_location = "nfs:fsf-lon0601b-fz.adn.networklayer.com:/IBM02SV625675_4/data01/ibm-cloud-private-x86_64-2.1.0.tar.gz"
    enterprise-edition = true

    /* Workaround for terraform issue #10857
     When this is fixed, we can work this out autmatically */

    cluster_size  = "${var.master["nodes"] + var.worker["nodes"] + var.proxy["nodes"]}"

    # Because SoftLayer private network uses 10.0.0.0/8 range, 
    # we will override default ICP network configuration 
    # to be sure to avoid conflict
    icp_configuration = {
      "network_cidr"              = "192.168.0.0/16"
      "service_cluster_ip_range"  = "172.16.0.1/24"
      "vip_iface"                 = "eth0"
      "cluster_vip"               = "10.72.16.23"
      "proxy_vip"                 = "10.72.16.24"
    }

    # We will let terraform generate a new ssh keypair 
    # for boot master to communicate with worker and proxy nodes
    # during ICP deployment
    generate_key = true
    
    # SSH user and key for terraform to connect to newly created SoftLayer resources
    # ssh_key is the private key corresponding to the public keyname specified in var.key_name
    ssh_user  = "root"
    ssh_key   = "~/.ssh/id_rsa"
    
} 
