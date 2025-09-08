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
