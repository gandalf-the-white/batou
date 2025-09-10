variable "userctn" { default = "root" }
variable "publkeyctn" { default = "~/.ssh/id_ed25519_proxmox.pub" }
variable "privkeyctn" { default = "~/.ssh/id_ed25519_proxmox" }
variable "token" {}
variable "token_id" {}
variable "fqdn_pmox" {}
variable "bridge" { default = "vmbr3" }
variable "docker_login" {}
variable "docker_password" {}

variable "proxy" { default = "" }
variable "nameserver" { default = "192.168.68.1" }
variable "target_node" { default = "proxmox" }
variable "cloudinit" { default = "local" }
variable "storage" { default = "local-lvm" }
variable "template" { default = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" }
# variable "template" { default = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst" }

variable "password" { default = "password" }

# watch "curl -o /dev/null -s -w 'Establish Connection: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n'  127.0.0.1:8000"

variable "oracles" {
  type = list(object({
    name    = string
    octet   = string
    memory  = number
    cores   = number
    sockets = number
    swap    = number
  }))
  default = [{
    name    = "oracle"
    octet   = "110"
    memory  = 2048
    cores   = 2
    sockets = 1
    swap    = 1024
  }]
}

variable "servers" {
  type = list(object({
    name          = string
    octet         = string # listener octet
    memory        = number
    cores         = number
    sockets       = number
    swap          = number
    natsport      = number # listener port
    leafport      = number # listener port for leaf
    socketport    = number
    clusterport   = number # cluster port
    octetregistry = string # listener octet for registry
    label         = string
    wadm          = string # wadm instance
    master        = string
  }))
  default = [
    {
      name          = "irland"
      octet         = "90"
      memory        = 2048
      cores         = 1
      sockets       = 1
      swap          = 256
      natsport      = 4222
      leafport      = 7422
      socketport    = 4223
      clusterport   = 6222
      octetregistry = "110"
      label         = "irland"
      wadm          = "true"
      master        = "true"
      }# , {
    #   name          = "england"
    #   octet         = "91"
    #   memory        = 2048
    #   cores         = 1
    #   sockets       = 1
    #   swap          = 256
    #   natsport      = 4222
    #   leafport      = 7422
    #   socketport    = 4223
    #   clusterport   = 6222
    #   octetregistry = "110"
    #   label         = "england"
    #   wadm          = "false"
    #   master        = "false"
    #   }, {
    #   name          = "france"
    #   octet         = "92"
    #   memory        = 2048
    #   cores         = 1
    #   sockets       = 1
    #   swap          = 256
    #   natsport      = 4222
    #   leafport      = 7422
    #   socketport    = 4223
    #   clusterport   = 6222
    #   octetregistry = "110"
    #   label         = "france"
    #   wadm          = "true"
    #   master        = "false"
    # }
  ]
}

variable "leafs" {
  type = list(object({
    name          = string
    octet         = string # listener octet
    memory        = number
    cores         = number
    sockets       = number
    swap          = number
    natsport      = number # listener port
    socketport    = number
    octetattach   = string # listener octet for leaf
    portattach    = number # listener port for leaf
    octetregistry = string # listener octet for registry
    label         = string
  }))
  default = [
    {
      name          = "dublin"
      octet         = "93"
      memory        = 2048
      cores         = 2
      sockets       = 1
      swap          = 512
      natsport      = 4222
      socketport    = 4223
      octetattach   = "90"
      portattach    = 7422
      octetregistry = "110"
      label         = "dublin"
      }# , {
    #   name          = "paris"
    #   octet         = "94"
    #   memory        = 2048
    #   cores         = 2
    #   sockets       = 1
    #   swap          = 256
    #   natsport      = 4222
    #   socketport    = 4223
    #   octetattach   = "92"
    #   portattach    = 7422
    #   octetregistry = "110"
    #   label         = "paris"
    # } , {
    #   name          = "galway"
    #   octet         = "95"
    #   memory        = 2048
    #   cores         = 2
    #   sockets       = 1
    #   swap          = 256
    #   natsport      = 4222
    #   socketport    = 4223
    #   octetattach   = "90"
    #   portattach    = 7422
    #   octetregistry = "110"
    #   label         = "galway"
    # }
  ]
}
