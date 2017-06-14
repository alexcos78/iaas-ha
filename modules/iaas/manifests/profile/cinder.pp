class iaas::profile::cinder (

#Cinder
  $password = undef,
  $secret = undef,

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

) {
  include iaas::resources::connectors

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

##Leave commented if database is different from controller
#  iaas::resources::database { 'cinder': }

  class { '::cinder':
##Verbose, debug
    verbose => $verbose,
    debug => $debug,
    database_connection => $iaas::resources::connectors::cinder,
##Added rabbit_hosts - uncomment as needed
#    rabbit_host => $endpoint,
    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_virtual_host => '/',
    database_idle_timeout => 3600,
  }

  class { '::cinder::glance':
    glance_api_servers => [ "${real_endpoint_admin}:9292" ],
  }

  class { '::cinder::keystone::auth':
    password => $password,
    public_url => "http://${endpoint_main}:8776/v1/%(tenant_id)s",
    internal_url => "http://${real_endpoint_admin}:8776/v1/%(tenant_id)s",
    admin_url => "http://${real_endpoint_admin}:8776/v1/%(tenant_id)s",
    public_url_v2 => "http://${endpoint_main}:8776/v2/%(tenant_id)s",
    internal_url_v2 => "http://${real_endpoint_admin}:8776/v2/%(tenant_id)s",
    admin_url_v2 => "http://${real_endpoint_admin}:8776/v2/%(tenant_id)s",
    public_url_v3 => "http://${endpoint_main}:8776/v3/%(tenant_id)s",
    internal_url_v3 => "http://${real_endpoint_admin}:8776/v3/%(tenant_id)s",
    admin_url_v3 => "http://${real_endpoint_admin}:8776/v3/%(tenant_id)s",
    region => $region,
  }

  class { '::cinder::api':
    identity_uri => "http://${real_endpoint_admin}:35357",
    auth_uri => "http://${endpoint_main}:5000",
    keystone_password => $password,
    bind_host => $::facts["ipaddress_${admin_interface}"],
  }

  class { '::cinder::scheduler':
#    scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler',
  }

  class { '::cinder::volume': }

  class { '::cinder::volume::rbd':
    rbd_pool => 'volumes',
    rbd_user => 'cinder',
    rbd_secret_uuid => $secret,
  }

  class { '::cinder::backup': }
  class { '::cinder::backup::ceph':
    backup_ceph_user => 'cinder-backup',
  }

}
