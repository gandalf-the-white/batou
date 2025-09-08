###################################################################################
##  L O C A L S
####################################################################################

locals {
  ssh_key = file(var.publkeyctn)
}

####################################################################################
##  RESOURCES
####################################################################################

resource "proxmox_lxc" "oracle_server" {
  onboot = true
  start = true
  count       = length(var.oracles)
  hostname = var.oracles[count.index].name
  target_node = var.target_node
  ostype       = "ubuntu"
  password     = var.password

  tags = "Ed;Nats"

  memory   = var.oracles[count.index].memory
  cores   = var.oracles[count.index].cores

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
    ip = "${var.prefix}.${var.oracles[count.index].octet}/24,gw=${var.prefix}.1"
  }
}

####################################################################################
##  OUTPUT
####################################################################################

# output "oracle_ip_address" {
#   description = "Oracle Servers IP Address"
#   value       = proxmox_lxc.oracle_server[*].default_ipv4_address
# }
