class iaas::profile::neutron::server (

  $public_interface = undef,
  $admin_interface = undef,

  $neutron_password = 'neutron',
  $nova_password = 'nova',

  $region = undef,
#VIP1
  $endpoint_main = undef,
#VIP2
  $endpoint_admin = undef,

) {
  include iaas::resources::connectors

##Leave commented if DB is not controller
#  iaas::resources::database { 'neutron': }

  include iaas::profile::neutron::common

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  class { '::neutron::server':
    auth_uri => "http://${endpoint_main}:5000/",
    auth_url => "http://${real_endpoint_admin}:35357/",
    password => $neutron_password,
    database_connection => $iaas::resources::connectors::neutron,
    database_idle_timeout => 3600,
    enabled => true,
    sync_db => true,
    l3_ha => false,
    allow_automatic_l3agent_failover => true,
    router_distributed => false,
    project_domain_id => 'default',
    user_domain_id => 'default',
  }

  class { '::neutron::keystone::auth':
    password => $neutron_password,
    public_url => "http://${endpoint_main}:9696",
    admin_url => "http://${real_endpoint_admin}:9696",
    internal_url => "http://${real_endpoint_admin}:9696",
    region => $region,
  }

  class { '::neutron::server::notifications':
    nova_url => "http://${real_endpoint_admin}:8774/v2",
    auth_url => "http://${real_endpoint_admin}:35357",
    password => $nova_password,
    region_name => $region,
    tenant_name => "services",
  } 

  class { '::neutron::services::lbaas':
    service_providers => [
      'LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default',
      'VPN:openswan:neutron_vpnaas.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default'
    ],
  }

  class {'::neutron::services::fwaas':
    enabled => true,
    driver => 'neutron.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
  }

#Support for neutron-l3 config variables
  class { '::neutron::agents::l3': 
    ha_enabled => true,
    enabled => false,
    package_ensure => 'absent',
    manage_service => 'false',
    external_network_bridge => ' ',
  }

  package { 'python-neutron-lbaas':
    ensure => 'installed',
  }

  package { 'python-neutron-vpnaas':
    ensure => 'installed',
  }

}
