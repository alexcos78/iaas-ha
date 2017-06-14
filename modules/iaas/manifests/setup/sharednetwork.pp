# A static class to set up a shared network. Should appear on the
# controller node. It sets up the public network(s), private network(s),
# subnets (for admin and for test), and (if enabled) the routers that
# connect the subnets to the public network(s).
#
# After this class has run, you should have a functional network
# avaiable for your test user to launch and connect machines to.
class iaas::setup::sharednetwork (

##Variable definition
 $external_network1 = undef,
 $gateway1  = undef,
 $start_ip1 = undef,
 $end_ip1   = undef,
# $private_network1 = undef,
 $external_network2 = undef,
 $gateway2  = undef,
 $start_ip2 = undef,
 $end_ip2   = undef,
# $private_network2 = undef,
 $dns      = undef,

) {

$ip_range1 = "start=${start_ip1},end=${end_ip1}"
$ip_range2 = "start=${start_ip2},end=${end_ip2}"

  neutron_network { 'public1':
    tenant_name              => 'admin',
    provider_network_type    => 'flat',
    router_external          => true,
    provider_physical_network => 'physnet1',
    shared                   => false,
  } ->
  neutron_subnet { "public1-$external_network1":
    cidr             => $external_network1,
    ip_version       => '4',
    gateway_ip       => $gateway1,
    enable_dhcp      => false,
    network_name     => 'public1',
    tenant_name      => 'admin',
    allocation_pools => [$ip_range1],
    dns_nameservers  => [$dns],
  }

  if $external_network2 {
    neutron_network { 'public2':
      tenant_name              => 'admin',
      provider_network_type    => 'flat',
      router_external          => true,
      provider_physical_network => 'physnet2',
      shared                   => false,
    } ->
    neutron_subnet { "public2-$external_network2":
      cidr             => $external_network2,
      ip_version       => '4',
      gateway_ip       => $gateway2,
      enable_dhcp      => false,
      network_name     => 'public2',
      tenant_name      => 'admin',
      allocation_pools => [$ip_range2],
      dns_nameservers  => [$dns],
    }
  }

# router setup for the tenant test
# Commented for production environments
#  iaas::setup::router { "test1:${private_network1}": }
#  if $external_network2 {
#    iaas::setup::router { "test2:${private_network2}": }
#  }

}
