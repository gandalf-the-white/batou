# The MIT License (MIT)

# Copyright (c) 2024 Laurent Valeyre

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

variable "userctn" { default = "spike" }
variable "publkeyctn" { default = "~/.ssh/id_ed25519_proxmox.pub" }
variable "privkeyctn" { default = "~/.ssh/id_ed25519_proxmox" }
variable "token" {}
variable "token_id" {}
variable "fqdn_pmox" {}
variable "bridge" { default = "vmbr3" }
variable "docker_login" {}
variable "docker_password" {}

# variable "proxy" { default = "http://proxy.rd.francetelecom.fr:8080" }
variable "proxy" { default = "" }
# variable "nameserver" { default = "10.192.65.254" }
variable "nameserver" { default = "192.168.68.1" }
variable "target_node" { default = "proxmox" }
variable "cloudinit" { default = "local" }
variable "storage" { default = "local-lvm" }
variable "template" { default = "ubuntu-2404-30" }

variable "subnet" { default = "192.188.200" }
variable "vlan" { default = "200" }

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
    memory  = 4096
    cores   = 2
    sockets = 1
    swap    = 1024
  }]
}

variable "harbors" {
  type = list(object({
    name    = string
    octet   = string
    memory  = number
    cores   = number
    sockets = number
    swap    = number
  }))
  default = [{
    name    = "harbor"
    octet   = "111"
    memory  = 6144
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
      memory        = 4096
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
    } # , {
    #   name          = "england"
    #   octet         = "91"
    #   memory        = 4096
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
    # }, {
    #   name          = "france"
    #   octet         = "92"
    #   memory        = 4096
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
    dev_enabled   = string # enable the dev environment
  }))
  default = [
    {
      name          = "dublin"
      octet         = "93"
      memory        = 4096
      cores         = 2
      sockets       = 1
      swap          = 512
      natsport      = 4222
      socketport    = 4223
      octetattach   = "90"
      portattach    = 7422
      octetregistry = "110"
      label         = "dublin"
      dev_enabled   = "true"
    } # , {
    #   name          = "paris"
    #   octet         = "94"
    #   memory        = 4096
    #   cores         = 2
    #   sockets       = 1
    #   swap          = 256
    #   natsport      = 4222
    #   socketport    = 4223
    #   octetattach   = "92"
    #   portattach    = 7422
    #   octetregistry = "110"
    #   label         = "paris"
    #   dev_enabled   = "false"
    # }, {
    #   name          = "galway"
    #   octet         = "95"
    #   memory        = 4096
    #   cores         = 2
    #   sockets       = 1
    #   swap          = 256
    #   natsport      = 4222
    #   socketport    = 4223
    #   octetattach   = "90"
    #   portattach    = 7422
    #   octetregistry = "110"
    #   label         = "galway"
    #   dev_enabled   = "false"
    # }
  ]
}
