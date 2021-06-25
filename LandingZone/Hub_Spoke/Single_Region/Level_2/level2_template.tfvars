poc_subscription_id = ""
Vpn_shared_key = "myvpnkey"
#your VPN/Router IP address: can be found with https://www.whatsmyip.org/
gateway_ip_address = "192.168.0.1" 
corp_prefix = "test"
domain_name = "test.com"
#your domain ip address used for vnet dns to join domain
domain_ip = "192.168.1.5"
domain_NetbiosName = "corp"
domain_admin_password = "changeme"
jump_host_password = "changeme"
#Addresses which will be known to Azure with your S2S Gateway
local_network_gateway_prefix = ["192.168.1.0/24","192.168.2.0/24"]
