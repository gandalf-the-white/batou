####################################################################################
## N A T S
####################################################################################

module "nats" {
  source       = "./modules/nats/"
  area         = "south"
  target_node  = var.target_node
  bridge       = var.bridge
  prefix       = var.subnet
  vlan         = var.vlan
  servers      = var.servers
  oracle       = var.oracles
  leafs        = var.leafs
  template     = var.template
  userctn      = var.userctn
  publkeyctn   = var.publkeyctn
  privkeyctn   = var.privkeyctn
  storage      = var.storage
  cloudinit    = var.cloudinit
  size         = 30
  clone        = var.template
  nameserver   = var.nameserver
  name_cluster = "wasmcloud"
  port_cluster = 6222
  proxy        = var.proxy
}

####################################################################################
## O R A C L E
####################################################################################

module "oracle" {
  source          = "./modules/oracle"
  area            = "south"
  target_node     = var.target_node
  bridge          = var.bridge
  prefix          = var.subnet
  vlan            = var.vlan
  oracles         = var.oracles
  servers         = var.servers
  leafs           = var.leafs
  template        = var.template
  userctn         = var.userctn
  publkeyctn      = var.publkeyctn
  privkeyctn      = var.privkeyctn
  storage         = var.storage
  cloudinit       = var.cloudinit
  size            = 30
  clone           = var.template
  nameserver      = var.nameserver
  name_cluster    = "wasmcloud"
  port_cluster    = 6222
  proxy           = var.proxy
  docker_login    = var.docker_login
  docker_password = var.docker_password
  depends_on      = [module.nats]
}

####################################################################################
## O U T P U T
####################################################################################

output "nats_south_ip_address" {
  description = "South Nats Servers IP Address"
  value       = module.nats
}

output "oracle_ip_address" {
  description = "Oracle Servers IP Address"
  value       = module.oracle
}
