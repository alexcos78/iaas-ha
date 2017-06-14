class iaas::profile::nova::common (
  $public_interface = $iaas::params::public_interface,
  $admin_interface = $iaas::params::admin_interface,

##verbose, debug
  $verbose = $iaas::params::os_verbose,
  $debug = $iaas::params::os_debug,

##present in mitaka release
#  $default_flotting_pool = $iaas::params::os_nova_fpool,
  $neutron_password = $iaas::params::os_neutron_passwd,
  $nova_password = $iaas::params::os_nova_passwd,

  $region = $iaas::params::os_region,
#VIP1
  $endpoint_main = $iaas::params::main_address,
#VIP2
  $endpoint_admin = $iaas::params::admin_address,

##rhosts
#  $endpoint = hiera('iaas::main_address', undef),
  $rhosts = $iaas::params::rhmk_ips,
  $rabbitmq_user = $iaas::params::rabbit_user,
  $rabbitmq_password = $iaas::params::rabbit_password,

# Memcache
  $memcache = $iaas::params::controller_ips,
) {
  include iaas::resources::connectors

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  class { '::nova':
    verbose => $verbose,
    debug => $debug,
    database_connection => $iaas::resources::connectors::nova,
    api_database_connection => $iaas::resources::connectors::novaapi,
    glance_api_servers => [ "http://${real_endpoint_admin}:9292" ],
##rabbit_hosts - uncomment as needed
#    rabbit_host => $endpoint,
#    rabbit_hosts => $rhosts,
    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_virtual_host => '/',
#dep mitaka
#    mysql_module => '2.3',
    database_idle_timeout => 3600,
# Memcache1.1.0
#    memcached_servers => $memcache,
    memcached_servers => suffix($memcache, ':11211'),
  }

  class { '::nova::network::neutron':
    neutron_password => $neutron_password,
    neutron_auth_url => "http://${real_endpoint_admin}:35357/v3",
    neutron_region_name => $region,
    neutron_url => "http://${real_endpoint_admin}:9696",

  }

# Set VNC host
  class { '::nova::vncproxy::common':
    vncproxy_host => $endpoint_main,
  }

  nova_config { 
   'DEFAULT/my_ip': value => $::facts["ipaddress_${admin_interface}"];
  }

}
