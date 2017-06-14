class iaas::profile::keystone (
  $admin_token = 12345678901234567890,
  $admin_email = 'admin@mail',
  $admin_password = 'admin',
  $admin_tenant = 'admin',

  $tenants = undef,
  $users = undef,

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

##Leave commented if DB is not controller
#  iaas::resources::database { 'keystone': }
  include iaas::resources::connectors

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  class { '::keystone':
##added verbose, debug
    verbose => $verbose,
    debug => $debug,
    admin_token => $admin_token,
    database_connection => $iaas::resources::connectors::keystone,
    admin_bind_host => $::facts["ipaddress_${admin_interface}"],
    public_bind_host => $::facts["ipaddress_${admin_interface}"],
    admin_endpoint => "http://${real_endpoint_admin}:35357",
##rhosts - uncomment as needed
#    rabbit_host => $endpoint,
    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    database_idle_timeout => 3600,
  }

  class { 'keystone::roles::admin':
    email => $admin_email,
    password => $admin_password,
    admin_tenant => $admin_tenant,
  } ->
#add mitaka
  keystone_role { '_member_':
      ensure => present,
    }

  class { 'keystone::endpoint':
    public_url => "http://${endpoint_main}:5000",
    admin_url => "http://${real_endpoint_admin}:35357",
    internal_url => "http://${real_endpoint_admin}:5000",
    region => $region,
#mitaka, defaults to 'v2.0' if unset by user; Valid values are 'v2.0', 'v3'
    version => 'v3',
  }

  create_resources('iaas::resources::tenant', $tenants)
  create_resources('iaas::resources::user', $users)

}
