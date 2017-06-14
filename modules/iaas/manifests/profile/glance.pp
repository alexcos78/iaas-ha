class iaas::profile::glance (
  $password = undef,

##verbose, debug
  $verbose = false,
  $debug = false,

  $public_interface = undef,
  $admin_interface = undef,

  $region = undef,

#VIP1
  $endpoint_main = undef,
#VIP2
  $endpoint_admin = undef,

##Rabbit hosts
  $rhosts = undef,
  $rabbitmq_user = undef,
  $rabbitmq_password = undef,

# Memcache
  $memcache = $iaas::params::controller_ips,

) {

  include iaas::resources::connectors

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  $rabbits = suffix($rhosts, ':5672')


  class { '::glance::api':
##verbose, debug
    verbose => $verbose,
    debug => $debug,
##Identity_uri - planed to be implemented in Kilo
    identity_uri => "http://${real_endpoint_admin}:35357",
    bind_host => $::facts["ipaddress_${admin_interface}"],
    keystone_password => $password,
    auth_uri => "http://${endpoint_main}:5000/v2.0",
    keystone_tenant => 'services',
    keystone_user => 'glance',
    database_connection => $iaas::resources::connectors::glance,
##registry_host
#    registry_host => $real_endpoint_admin,
    registry_host => $::facts["ipaddress_${admin_interface}"],
    database_idle_timeout => 3600,
    os_region_name => $region,
#deprecated in newton
    known_stores => ['glance.store.filesystem.Store', 'glance.store.http.Store', 'glance.store.rbd.Store', 'glance.store.cinder.Store'],
#    known_stores => ['glance.store.filesystem.Store', 'glance.store.http.Store', 'glance.store.rbd.Store', 'glance.store.cinder.Store'], 
#  'glance.store.sheepdog.Store', 'glance.store.vmware_datastore.Store', 'glance.store.s3.Store', 'glance.store.swift.Store'
    show_image_direct_url => true,
##For GPFS
#    show_multiple_locations => true,
    pipeline => 'keystone',
#mitaka, memcache
    memcached_servers => suffix($memcache, ':11211'),
  }

##Identity_uri - workaround in juno
#  glance_api_config { 'keystone_authtoken/identity_uri' :
#    value => "http://${real_endpoint_admin}:35357",
#  }

  class { '::glance::backend::rbd':
    rbd_store_user => 'glance',
    rbd_store_ceph_conf => '/etc/ceph/ceph.conf',
    rbd_store_pool => 'images',
  }

  class { '::glance::registry':
    verbose => $verbose,
    debug => $debug,
##Identity_uri - planed to be implemented
    identity_uri => "http://${real_endpoint_admin}:35357",
    keystone_password => $password,
    database_connection => $iaas::resources::connectors::glance,
    auth_uri => "http://${endpoint_main}:5000/v2.0",
    keystone_tenant => 'services',
    keystone_user => 'glance',
    database_idle_timeout => 3600,
    bind_host => $::facts["ipaddress_${admin_interface}"],
    os_region_name => $region,
    pipeline => 'keystone',
#mitaka, memcache
    memcached_servers => suffix($memcache, ':11211'),
  }

##Identity_uri - workaround in juno
#  glance_registry_config { 'keystone_authtoken/identity_uri' :
#    value => "http://${real_endpoint_admin}:35357",
#  }

  class { '::glance::notify::rabbitmq':
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
##rabbit_hosts - uncomment as needed
#    rabbit_host => $endpoint,
#    rabbit_hosts => $rhosts,
#    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_hosts => $rabbits,
    rabbit_virtual_host => '/',
  }

##Leave commented if DB is not controller
#  iaas::resources::database { 'glance': }

  class  { '::glance::keystone::auth':
    password => $password,
    public_url => "http://${endpoint_main}:9292",
    admin_url => "http://${real_endpoint_admin}:9292",
    internal_url => "http://${real_endpoint_admin}:9292",
    region => $region,
  }

}
