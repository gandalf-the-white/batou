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
  onboot      = true
  start       = true
  count       = length(var.oracles)
  hostname    = var.oracles[count.index].name
  target_node = var.target_node
  ostype      = "ubuntu"
  password    = var.password

  tags = "Ed;Nats"

  memory = var.oracles[count.index].memory
  cores  = var.oracles[count.index].cores

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
    name   = "eth0"
    bridge = var.bridge
    tag    = var.vlan
    ip     = "${var.prefix}.${var.oracles[count.index].octet}/24,gw=${var.prefix}.1"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl start ssh",
      "hostnamectl set-hostname ${var.oracles[count.index].name}"
    ]

    connection {
      host        = "${var.prefix}.${var.oracles[count.index].octet}"
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
      name       = "oracle"
      octet      = 240
      oracles    = var.oracles
      servers    = var.servers
      leafs      = var.leafs
      prefix     = var.prefix
      userctn    = var.userctn
      privkeyctn = var.privkeyctn
  })
  filename        = "./ansible/inventory-oracle.yaml"
  file_permission = "0644"
}

resource "local_file" "playbook" {
  content = templatefile("${path.module}/manifests/playbook-template.yaml",
    {
      name_cluster   = var.name_cluster
      port_cluster   = var.port_cluster
      oracles        = var.oracles
      servers        = var.servers
      leafs          = var.leafs
      prefix         = var.prefix
      area           = var.area
      dockerlogin    = var.docker_login
      dockerpassword = var.docker_password
      nscdirectory   = "/srv/jwt"
      proxy          = var.proxy
      noproxy        = "127.0.0.1,localhost"
  })
  filename        = "./ansible/playbook-oracle.yaml"
  file_permission = "0644"
}

resource "null_resource" "play_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory-oracle.yaml ansible/playbook-oracle.yaml"
  }
  depends_on = [
    proxmox_lxc.oracle_server,
    local_file.inventory,
    local_file.playbook,
  ]
}


####################################################################################
##  OUTPUT
####################################################################################

# output "oracle_ip_address" {
#   description = "Oracle Servers IP Address"
#   value       = proxmox_lxc.oracle_server[*].default_ipv4_address
# }
