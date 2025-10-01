###################################################################################
##  L O C A L S
####################################################################################

locals {
}

####################################################################################
##  RESOURCES
####################################################################################

resource "proxmox_vm_qemu" "harbor_server" {
  count       = length(var.harbors)
  name        = "harbor"
  target_node = var.target_node
  clone       = var.clone

  os_type  = "cloud-init"
  memory   = var.harbors[count.index].memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  agent    = 1

  cpu {
    cores   = var.harbors[count.index].cores
    sockets = var.harbors[count.index].sockets
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

  ipconfig0  = "ip=${var.prefix}.${var.harbors[count.index].octet}/24,gw=${var.prefix}.1"
  nameserver = var.nameserver


  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo hostnamectl set-hostname ${var.harbors[count.index].name}"
    ]

    connection {
      host        = "${var.prefix}.${var.harbors[count.index].octet}"
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
      name       = "harbor"
      octet      = 240
      harbors    = var.harbors
      servers    = var.servers
      leafs      = var.leafs
      prefix     = var.prefix
      userctn    = var.userctn
      privkeyctn = var.privkeyctn
  })
  filename        = "./ansible/inventory-harbor.yaml"
  file_permission = "0644"
}

resource "local_file" "playbook" {
  content = templatefile("${path.module}/manifests/playbook-template.yaml",
    {
      name_cluster   = var.name_cluster
      port_cluster   = var.port_cluster
      harbors        = var.harbors
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
  filename        = "./ansible/playbook-harbor.yaml"
  file_permission = "0644"
}

resource "null_resource" "play_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory-harbor.yaml ansible/playbook-harbor.yaml"
  }
  depends_on = [
    proxmox_vm_qemu.harbor_server,
    local_file.inventory,
    local_file.playbook,
  ]
}

####################################################################################
##  OUTPUT
####################################################################################

output "harbor_ip_address" {
  description = "Harbor Servers IP Address"
  value       = proxmox_vm_qemu.harbor_server[*].default_ipv4_address
}
