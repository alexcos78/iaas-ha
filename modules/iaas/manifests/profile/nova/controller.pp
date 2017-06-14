class iaas::profile::nova::controller (
  $public_interface = undef,
  $admin_interface = undef,

#Nova
  $password = 'nova',

#Neutron
  $neutron_secret = undef,
  $neutron_password = 'neutron',

  $region = undef,
#VIP1
  $endpoint_main = undef,
#VIP2
  $endpoint_admin = undef,

# Memcache
  $memcache = $iaas::params::controller_ips,
) {
  include iaas::resources::connectors

##Leave commented if DB is not controller
#  iaas::resources::database { 'nova': }

  include iaas::profile::nova::common

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }
  
#  $memcache_real = suffix($memcache, ':11211')
  $memcache_real = join(any2array(suffix($memcache, ':11211')), ',')

#Print variables
#  notify {"debug message: $memcache and $memcache_real":
#      loglevel => alert,
#   }

  class { '::nova::keystone::auth':
    password => $password,
    public_url => "http://${endpoint_main}:8774/v2/%(tenant_id)s",
    internal_url => "http://${real_endpoint_admin}:8774/v2/%(tenant_id)s",
    admin_url => "http://${real_endpoint_admin}:8774/v2/%(tenant_id)s",
    public_url_v3 => "http://${endpoint_main}:8774/v3",
    internal_url_v3 => "http://${real_endpoint_admin}:8774/v3",
    admin_url_v3 => "http://${real_endpoint_admin}:8774/v3",
    region => $region,
  }

  class { '::nova::api':
    enabled => true,
    admin_password => $password,
    auth_uri => "http://${endpoint_main}:5000/",
    identity_uri => "http://${real_endpoint_admin}:35357/",
    neutron_metadata_proxy_shared_secret => $neutron_secret,
    api_bind_address => $::facts["ipaddress_${admin_interface}"],
    metadata_listen => $::facts["ipaddress_${admin_interface}"],
#not in mitaka
#keystone_ec2_url
#    keystone_ec2_url => $endpoint_main,
  }

  class { '::nova::vncproxy':
    enabled => true,
    host => $::facts["ipaddress_${admin_interface}"],
  }

# Set VNC-server variables
  nova_config {
    'DEFAULT/vncserver_listen' :                        value =>$::facts["ipaddress_${admin_interface}"];
    'DEFAULT/vncserver_proxyclient_address' :           value =>$::facts["ipaddress_${admin_interface}"];
    'DEFAULT/use_neutron' :                         value => 'true'; 
    'vnc/vncserver_listen' :                        value =>$::facts["ipaddress_${admin_interface}"];
    'vnc/vncserver_proxyclient_address' :           value =>$::facts["ipaddress_${admin_interface}"];
    'cache/backend' :                               value => 'oslo_cache.memcache_pool';
    'cache/enabled' :                               value => 'true';
    'cache/memcache_servers' :                               value => $memcache_real;
  }

#Set memcached variables for VNC console
  class { '::memcached':
    listen_ip => $::facts["ipaddress_${admin_interface}"],
  }

#mitaka add
  class { [ 'nova::scheduler', 'nova::consoleauth', 'nova::conductor']:
    enabled => true,
  }


}
