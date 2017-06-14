class iaas::profile::heat (

##Heat
  $password = undef,
  $encryption_key = undef,

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

##Leave commented if DB is not controller
#  iaas::resources::database { 'heat': }

  class { '::heat::keystone::auth':
    password => $password,
#not in mitaka
#    public_address => $endpoint_main,
#    admin_address => $real_endpoint_admin,
#    internal_address => $real_endpoint_admin,
#mitaka
    public_url => "http://${endpoint_main}:8004/v1/%(tenant_id)s",
    admin_url => "http://${$real_endpoint_admin}:8004/v1/%(tenant_id)s",
    internal_url => "http://${$real_endpoint_admin}:8004/v1/%(tenant_id)s",
    region => $region,
    configure_delegated_roles => true,
  }
  class { '::heat::keystone::auth_cfn':
    password => $password,
    public_address => "${endpoint_main}:8000/v1",
    admin_address => "${real_endpoint_admin}:8000/v1",
    internal_address => "${real_endpoint_admin}:8000/v1",
    region => $region,
  }

  class { '::heat':
##verbose, debug
    verbose => $verbose,
    debug => $debug,
    database_connection => $iaas::resources::connectors::heat,
##rabbit_hosts - uncomment as needed
#    rabbit_host => $endpoint,
#    rpc_backend => "rabbit",
#    rabbit_hosts => $rhosts,
    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_virtual_host => '/',    
#mitaka
#    auth_uri => "http://${endpoint_main}:5000/v2.0",
    auth_uri => "http://${endpoint_main}:5000/",
##Identity_uri - mitaka#
    identity_uri => "http://${real_endpoint_admin}:35357/",
#dep mitaka
#    keystone_host => $real_endpoint_admin,
    keystone_password => $password,
#mitaka
#    mysql_module => '2.3',
    database_idle_timeout => 3600,
#    region_name => $region,
#mitaka
    keystone_ec2_uri => "http://${endpoint_main}:5000/v2.0/ec2tokens",
  }

  class { '::heat::api':
    bind_host => $::facts["ipaddress_${admin_interface}"],
  }
  class { '::heat::api_cfn':
    bind_host => $::facts["ipaddress_${admin_interface}"],
  }
  class { '::heat::api_cloudwatch': 
    bind_host => $::facts["ipaddress_${admin_interface}"],
  }

  class { '::heat::engine':
    auth_encryption_key => $encryption_key,
    heat_metadata_server_url => "http://${endpoint_main}:8000",
    heat_waitcondition_server_url => "http://${endpoint_main}:8000/v1/waitcondition",
    heat_watch_server_url => "http://${endpoint_main}:8003",
  }

  file { "/usr/bin/heat-keystone-setup-domain":
      mode   => 550,
      owner  => root,
      group  => root,
      source => "puppet:///modules/iaas/heat-keystone-setup-domain"
  } ->

  class { 'heat::keystone::domain':
#deprecated mitaka
#    auth_url => "http://${real_endpoint_admin}:35357/v2.0",
#    keystone_admin => "heat",
#    keystone_password => $password,
#    keystone_tenant   => "services",
    domain_name => 'heat',
    domain_admin => 'heat_domain_admin',
    domain_password => 'heat_admin',
  }

##Identity_uri - workaround in juno
#  heat_config {
#    'keystone_authtoken/identity_uri' :value => "http://${real_endpoint_admin}:35357";
#  }

}
