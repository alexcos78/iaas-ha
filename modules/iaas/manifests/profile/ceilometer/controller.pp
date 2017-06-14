class iaas::profile::ceilometer::controller (
  $public_interface = undef,
  $admin_interface = undef,

  $password = 'ceilometer',

  $region = undef,

  $coordination_ip = undef,

#VIP1
  $endpoint_main = undef,
#VIP2
  $endpoint_admin = undef,

) {
  include iaas::resources::connectors

##Leave commented if DB is not controller
#  iaas::resources::database { 'ceilometer': }

  include iaas::profile::ceilometer::common

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  $admin_ip = $::facts["ipaddress_${admin_interface}"]

  $coordination_ip_port = suffix($coordination_ip, ':2181')
  $real_coordination_ip = join($coordination_ip_port, ',')

  class { '::ceilometer::keystone::auth':
    password => $password,
    public_url => "http://${endpoint_main}:8777",
    admin_url => "http://${real_endpoint_admin}:8777",
    internal_url => "http://${real_endpoint_admin}:8777",
    region => $region,
  }

  class { '::ceilometer::api':
    host => $::facts["ipaddress_${admin_interface}"],
    enabled => true,
    keystone_password => $password,
    auth_uri => "http://${endpoint_main}:5000/",
    identity_uri => "http://${real_endpoint_admin}:35357/",
  }

  class { '::ceilometer::db':
    database_connection => $iaas::resources::connectors::ceilometer,
    database_idle_timeout => 3600,
  }

# Python-zake package
  package { 'python-zake': }

# Moved to a self-consistent profile
# with the following variables (see variable declaration on top):
#  $servers = hiera('iaas::profile::ceilometer::servers', undef),
#  $zookeeper_id = undef,
#  $zookeeper_max_connections = 128,
#
# Python-zake package
#  package { 'python-zake': }
#
#  class { 'zookeeper':
#    id => $zookeeper_id,
#    client_ip => $::facts["ipaddress_${admin_interface}"],
#    servers => $servers,
#    max_allowed_connections => $zookeeper_max_connections,
#  }

  class { '::ceilometer::agent::central':
    coordination_url => "kazoo://${$real_coordination_ip}",
  }

  class { '::ceilometer::expirer': }

  class { '::ceilometer::alarm::notifier': }
  class { '::ceilometer::collector': }
  class { '::ceilometer::agent::notification': }

}
