provider "softlayer" {
    username = "${var.sl_username}"
    api_key = "${var.sl_api_key}"
}

data "softlayer_ssh_key" "public_key" {
  label = "${var.key_name}"
}

resource "softlayer_virtual_guest" "glustercluster" {
    count       = "${var.gluster["nodes"]}"
    
    datacenter  = "${var.datacenter}"
    domain      = "${var.domain}"
    hostname    = "${format("${lower(var.instance_name)}-glusternode%01d", count.index + 1) }"
    
    os_reference_code = "UBUNTU_16_64"

    cores       = "${var.gluster["cpu_cores"]}"
    memory      = "${var.gluster["memory"]}"
    disks       = ["${var.gluster["root_disk_size"]}"]
    local_disk  = "${var.gluster["local_disk"]}"
    network_speed         = "${var.gluster["network_speed"]}"
    hourly_billing        = "${var.gluster["hourly_billing"]}"
    private_network_only  = "${var.gluster["private_network_only"]}"

    user_metadata = "{\"value\":\"newvalue\"}"

    ssh_key_ids = ["${data.softlayer_ssh_key.public_key.id}"]
}

# Setup the glusterfs on all cluster nodes 
resource "null_resource" "gluster" {
 
  count = "${var.gluster["nodes"]}"
  
  connection {
    host = "${element(softlayer_virtual_guest.glustercluster.*.ipv4_address, count.index)}"
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_key)}"
  }

  ## TODO: Probably not needed anymore
  # Upload cluster list
  provisioner "file" {
    content = "${join(",", softlayer_virtual_guest.glustercluster.*.ipv4_address_private)}"
    destination = "/tmp/clusterips.txt"
  }
  
  ## TODO: Probably not needed anymore
  provisioner "file" {
    content = "${join(",", softlayer_virtual_guest.glustercluster.*.hostname)}"
    destination = "/tmp/clusternames.txt"
  }

  provisioner "file" {
    content = "${join("", formatlist("%s     %s\n", softlayer_virtual_guest.glustercluster.*.ipv4_address_private,softlayer_virtual_guest.glustercluster.*.hostname))}"
    destination = "/tmp/glusterhosts.txt"
  }
 
  # Setup hosts and firewall
  provisioner "remote-exec" {
    scripts = [
      "cat /tmp/glusterhosts.txt | sudo tee -a /etc/hosts",
      "scripts/setup-firewall.sh"
    ]
  }
  
  # Setup glusterfs software
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository -y ppa:gluster/glusterfs-3.12",
      "sudo apt-get update",
      "sudo apt-get install -y glusterfs-server",
      "sudo service glusterd start",
      "sudo mkdir -p /data/gluster/icprepository",
      "sudo mkdir -p /data/gluster/icpaudit"
    ]
  }

#  # Setup backing hard drive
#  provisioner "file" {
#    source = "scripts/setup-disk.sh"
#    destination = "/tmp/setup-disk.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "/tmp/setup-disk.sh /dev/xvdc",
#    ]
#  }
  
}


resource "null_resource" "glusterconfig" {
  # Configuration can be run on only a single node
 
  depends_on = ["null_resource.gluster"]
  
  connection {
    host = "${element(softlayer_virtual_guest.glustercluster.*.ipv4_address, 0)}"
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_key)}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "for host in ${join(" ", softlayer_virtual_guest.glustercluster.*.hostname)}; do gluster peer probe $host && echo \"Peer Probe: $host\"; done",
      "sleep 7; sudo gluster peer status",
      "sudo gluster volume create icprepository replica ${var.gluster["nodes"]} ${join(" ", formatlist("%s:/data/gluster/icprepository", softlayer_virtual_guest.glustercluster.*.hostname))} force",
      "sudo gluster volume start icprepository",
      "sudo gluster volume create icpaudit replica ${var.gluster["nodes"]} ${join(" ", formatlist("%s:/data/gluster/icpaudit", softlayer_virtual_guest.glustercluster.*.hostname))} force",
      "sudo gluster volume start icpaudit",
      "sleep 4; sudo gluster volume info icprepository",
      "sleep 4; sudo gluster volume info icpaudit"
    ]
  }

}
