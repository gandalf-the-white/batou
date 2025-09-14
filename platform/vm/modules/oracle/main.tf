###################################################################################
##  L O C A L S
####################################################################################

locals {
}

####################################################################################
##  RESOURCES
####################################################################################

resource "proxmox_vm_qemu" "oracle_server" {
  count       = length(var.oracles)
  name        = "oracle"
  target_node = var.target_node
  clone       = var.clone

  os_type  = "cloud-init"
  memory   = var.oracles[count.index].memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  agent    = 1

  cpu {
    cores   = var.oracles[count.index].cores
    sockets = var.oracles[count.index].sockets
    type    = "host"
  }

  tags = "Ed;Nats"

  cicustom = "user=${var.cloudinit}:snippets/cloudinit.yaml"

  disks {
    ide {
      ide3 {
        cloudinit {
          storage = var.storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = var.size
          storage = var.storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
    tag    = var.vlan
  }

  ipconfig0  = "ip=${var.prefix}.${var.oracles[count.index].octet}/24,gw=${var.prefix}.1"
  nameserver = var.nameserver


  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo hostnamectl set-hostname ${var.oracles[count.index].name}"
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
    proxmox_vm_qemu.oracle_server,
    local_file.inventory,
    local_file.playbook,
  ]
}

####################################################################################
##  OUTPUT
####################################################################################

output "oracle_ip_address" {
  description = "Oracle Servers IP Address"
  value       = proxmox_vm_qemu.oracle_server[*].default_ipv4_address
}
