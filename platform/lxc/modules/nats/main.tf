###################################################################################
##  L O C A L S
####################################################################################

locals {
  ssh_key = file(var.publkeyctn)
}

####################################################################################
##  RESOURCES
####################################################################################

resource "proxmox_lxc" "nats_server" {
  onboot = true
  start = true
  count       = length(var.servers)
  hostname = var.servers[count.index].name
  target_node = var.target_node
  ostype       = "ubuntu"
  password     = var.password

  tags = "Ed;Nats"

  memory   = var.servers[count.index].memory
  cores   = var.servers[count.index].cores

  nameserver = var.nameserver

  ssh_public_keys = <<EOT
    ${local.ssh_key}
  EOT

  ostemplate = var.clone

  rootfs {
    storage = var.storage
    size    = var.size
  }

  network {
    name = "eth0"
    bridge = var.bridge
    tag = var.vlan
    ip = "${var.prefix}.${var.servers[count.index].octet}/24,gw=${var.prefix}.1"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart ssh",
      "hostnamectl set-hostname ${var.area}-${var.servers[count.index].name}"
    ]

    connection {
      host        = "${var.prefix}.${var.servers[count.index].octet}"
      type        = "ssh"
      user        = var.userctn
      private_key = file(var.privkeyctn)
    }
  }
}

resource "proxmox_lxc" "nats_leaf" {
  onboot = true
  start = true
  count       = length(var.leafs)
  hostname = var.leafs[count.index].name
  target_node = var.target_node
  ostype       = "ubuntu"
  password     = var.password

  tags = "Ed;Nats"

  memory   = var.leafs[count.index].memory
  cores   = var.leafs[count.index].cores

  nameserver = var.nameserver

  ssh_public_keys = <<EOT
    ${local.ssh_key}
  EOT

  ostemplate = var.clone

  rootfs {
    storage = var.storage
    size    = var.size
  }

  network {
    name = "eth0"
    bridge = var.bridge
    tag = var.vlan
    ip = "${var.prefix}.${var.leafs[count.index].octet}/24,gw=${var.prefix}.1"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart ssh",
      "hostnamectl set-hostname ${var.area}-${var.leafs[count.index].name}"
    ]

    connection {
      host        = "${var.prefix}.${var.leafs[count.index].octet}"
      type        = "ssh"
      user        = var.userctn
      private_key = file(var.privkeyctn)
    }
  }
}

####################################################################################
##  ANSIBLE
####################################################################################

resource "local_file" "inventory" {
  content = templatefile("${path.module}/manifests/inventory-template.yaml",
    {
      servers    = var.servers
      leafs      = var.leafs
      prefix     = var.prefix
      userctn    = var.userctn
      privkeyctn = var.privkeyctn
  })
  filename        = "./ansible/inventory-nats.yaml"
  file_permission = "0644"
}

resource "local_file" "playbook" {
  content = templatefile("${path.module}/manifests/playbook-template.yaml",
    {
      name_cluster = var.name_cluster
      port_cluster = var.port_cluster
      servers      = var.servers
      leafs        = var.leafs
      prefix       = var.prefix
      oracle       = var.oracle
      area         = var.area
      proxy        = var.proxy
      noproxy      = "127.0.0.1,localhost"
  })
  filename        = "./ansible/playbook-nats.yaml"
  file_permission = "0644"
}

resource "null_resource" "delete_credentials" {
  provisioner "local-exec" {
    command = "rm -f ./ansible/credentials/*.creds "
    when    = destroy
  }
  depends_on = [
    proxmox_lxc.nats_server,
    proxmox_lxc.nats_leaf,
    local_file.inventory,
    local_file.playbook
  ]
}

resource "null_resource" "play_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory-nats.yaml ansible/playbook-nats.yaml"
  }
  depends_on = [
    proxmox_lxc.nats_server,
    local_file.inventory,
    local_file.playbook
  ]
}

####################################################################################
##  OUTPUT
####################################################################################

# output "nats_server_ip_address" {
#   description = "Nats Servers IP Address"
#   value       = proxmox_lxc.nats_server[*]
# }

# output "nats_leaf_ip_address" {
#   description = "Nats Leafs IP Address"
#   value       = proxmox_lxc.nats_leaf[*]
# }
