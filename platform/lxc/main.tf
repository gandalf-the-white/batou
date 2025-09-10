
####################################################################################
## N A T S
####################################################################################

module "nats" {
  source       = "./modules/nats/"
  area         = "south"
  target_node  = var.target_node
  bridge       = var.bridge
  prefix       = "192.188.200"
  vlan         = "200"
  servers      = var.servers
  oracle       = "192.188.200.110"
  leafs        = var.leafs
  template     = var.template
  userctn      = var.userctn
  publkeyctn   = var.publkeyctn
  privkeyctn   = var.privkeyctn
  storage      = var.storage
  cloudinit    = var.cloudinit
  size         = "8G"
  clone        = var.template
  nameserver   = var.nameserver
  name_cluster = "wasmcloud"
  port_cluster = 6222
  proxy        = var.proxy
  password     = var.password
}

####################################################################################
## O R A C L E
####################################################################################

# module "oracle" {
#   source          = "./modules/oracle"
#   area            = "south"
#   target_node     = var.target_node
#   bridge          = var.bridge
#   prefix          = "192.188.200"
#   vlan            = "200"
#   oracles         = var.oracles
#   servers         = var.servers
#   leafs           = var.leafs
#   template        = var.template
#   userctn         = var.userctn
#   publkeyctn      = var.publkeyctn
#   privkeyctn      = var.privkeyctn
#   storage         = var.storage
#   cloudinit       = var.cloudinit
#   size            = "8G"
#   clone           = var.template
#   nameserver      = var.nameserver
#   name_cluster    = "wasmcloud"
#   port_cluster    = 6222
#   proxy           = var.proxy
#   docker_login    = var.docker_login
#   docker_password = var.docker_password
#   password        = var.password
#   depends_on      = [module.nats]
# }

####################################################################################
## O U T P U T
####################################################################################

# output "nats_south_ip_address" {
#   description = "South Nats Servers IP Address"
#   value       = module.nats
# }

# output "oracle_ip_address" {
#   description = "Oracle Servers IP Address"
#   value       = module.oracle
# }
