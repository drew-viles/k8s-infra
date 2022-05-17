//create nodes
//start nodes - presumes you have auto provision configured/ami equivalent
//connect to nodes - should be done during provision
//configure network - should be done during provision
//configure firewall -

resource "libvirt_domain" "control-plane-nodes" {
  count = var.number_of_control_plane_nodes
  name = "controller-${count.index}"
  connection {
    type     = "ssh"
    user     = "root"
    password = var.private_key
    host     = self.public_ip
  }
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }
}

resource "libvirt_domain" "worker-nodes" {
  count = var.number_of_worker_nodes
  name = "worker-${count.index}"
}

resource "libvirt_domain" "etcd-nodes" {
  count = var.number_of_etcd_nodes
  name = "etcd-${count.index}"
}