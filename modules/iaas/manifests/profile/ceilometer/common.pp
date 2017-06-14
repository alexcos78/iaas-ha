class iaas::profile::ceilometer::common (
  $secret = $iaas::params::os_ceilometer_secret,

  $password = $iaas::params::os_ceilometer_passwd,
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

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  class { '::ceilometer':
    metering_secret => $secret,
##rabbit_hosts - uncomment as needed
#    rabbit_hosts => [ $endpoint ],
#    rabbit_hosts => $rhosts,
    rabbit_hosts => suffix($rhosts, ':5672'),
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
#mitaka
    rabbit_virtual_host => '/',
#mitaka, memcache
    memcached_servers => suffix($memcache, ':11211'),
  }

  class { '::ceilometer::agent::auth':
    auth_url => "http://${endpoint_main}:5000/v2.0",
    auth_password => $password,
    auth_region => $region,
  }

}
