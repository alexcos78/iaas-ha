class iaas::profile::neutron::common (
  $public_interface = $iaas::params::public_interface,
  $admin_interface = $iaas::params::admin_interface,

  $core_plugin = $iaas::params::os_neutron_corepl,
  $service_plugins = $iaas::params::os_neutron_servicepl,
  $external_device2 = $iaas::params::external_device2,

##verbose, debug
  $verbose = $iaas::params::os_verbose,
  $debug = $iaas::params::os_debug,

  $region = $iaas::params::os_region,

##rhosts
  $rhosts = $iaas::params::rhmk_ips,
  $rabbitmq_user = $iaas::params::rabbit_user,
  $rabbitmq_password = $iaas::params::rabbit_password,

##MTU VM
  $mtu = $iaas::params::mtu,
) {

  file { "/etc/init/neutron-l3-agent.conf":
    ensure => 'present',
  }

  class { '::neutron':
##added verbose, debug
    verbose => $verbose,
    debug => $debug,
    bind_host => $::facts["ipaddress_${admin_interface}"],
    bind_port => '9696',
    core_plugin => $core_plugin,
    allow_overlapping_ips => true,
##rabbit_hosts - uncomment as needed
#    rabbit_host => $endpoint,
#    rabbit_hosts => $rhosts,
    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_user => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_virtual_host => '/',
    service_plugins => $service_plugins,
    dhcp_agents_per_network => 2
  }

  if $external_device2 {
    $network_vlan_ranges='physnet1,physnet2'
  } else {
    $network_vlan_ranges='physnet1'
  }

#mitaka
  class  { '::neutron::plugins::ml2':
    type_drivers => ['gre', 'flat'],
    tenant_network_types => ['gre'],
    mechanism_drivers => ['openvswitch'],
#mitaka: to enable il internal domanin is different fron openstacklocal
#    extension_drivers => ['dns'],
#double_external_network, variable commented
#    flat_networks => ["external"],
    tunnel_id_ranges => ['10:1000'],
#double_external_network, variable added
    network_vlan_ranges => [$network_vlan_ranges],
    enable_security_group => true,
    path_mtu => $mtu,
    firewall_driver => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
  }
}

