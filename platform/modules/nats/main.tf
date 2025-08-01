###################################################################################
##  L O C A L S
####################################################################################

locals {
}

####################################################################################
##  RESOURCES
####################################################################################

resource "proxmox_vm_qemu" "nats_server" {
  count       = length(var.servers)
  desc        = "Deploiement VM Ubuntu on Proxmox"
  name        = "${var.area}-${var.servers[count.index].name}"
  target_node = var.target_node
  clone       = var.clone

  os_type  = "cloud-init"
  memory   = var.servers[count.index].memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  agent    = 1

  cpu {
    cores   = var.servers[count.index].cores
    sockets = var.servers[count.index].sockets
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

  ipconfig0  = "ip=${var.prefix}.${var.servers[count.index].octet}/24,gw=${var.prefix}.1"
  nameserver = var.nameserver


  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo hostnamectl set-hostname ${var.area}-${var.servers[count.index].name}"
    ]

    connection {
      host        = "${var.prefix}.${var.servers[count.index].octet}"
      type        = "ssh"
      user        = var.userctn
      private_key = file(var.privkeyctn)
    }
  }
}

resource "proxmox_vm_qemu" "nats_leaf" {
  count       = length(var.leafs)
  desc        = "Deploiement VM Ubuntu on Proxmox"
  name        = "${var.area}-${var.leafs[count.index].name}"
  target_node = var.target_node
  clone       = var.clone

  os_type  = "cloud-init"
  memory   = var.leafs[count.index].memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  agent    = 1

  cpu {
    cores   = var.leafs[count.index].cores
    sockets = var.leafs[count.index].sockets
    type    = "host"
  }
  tags = "Ed;Nats"


  cicustom = "user=${var.cloudinit}:snippets/cloudinit.yaml"
  # cloudinit_cdrom_storage = var.storage

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

  ipconfig0  = "ip=${var.prefix}.${var.leafs[count.index].octet}/24,gw=${var.prefix}.1"
  nameserver = var.nameserver


  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo hostnamectl set-hostname ${var.area}-${var.leafs[count.index].name}"
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
    proxmox_vm_qemu.nats_server,
    proxmox_vm_qemu.nats_leaf,
    local_file.inventory,
    local_file.playbook
  ]
}

resource "null_resource" "play_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory-nats.yaml ansible/playbook-nats.yaml"
  }
  depends_on = [
    proxmox_vm_qemu.nats_server,
    local_file.inventory,
    local_file.playbook
  ]
}

####################################################################################
##  OUTPUT
####################################################################################

output "nats_server_ip_address" {
  description = "Nats Servers IP Address"
  value       = proxmox_vm_qemu.nats_server[*].default_ipv4_address
}

output "nats_leaf_ip_address" {
  description = "Nats Leafs IP Address"
  value       = proxmox_vm_qemu.nats_leaf[*].default_ipv4_address
}
