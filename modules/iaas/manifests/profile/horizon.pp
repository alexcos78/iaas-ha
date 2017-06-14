class iaas::profile::horizon (

  $secret = undef,

  $endpoint_address = undef,
  $endpoint_servers = undef,

  $public_interface = undef,
  $admin_interface = undef,

) {

  class { '::horizon':
    allowed_hosts => '*',
    server_aliases => union([$endpoint_address, $::facts["ipaddress_${public_interface}"]], $endpoint_servers),
    secret_key => $secret,
    cache_server_ip => $::facts["ipaddress_${admin_interface}"],
    cache_server_port     => '11211',
    keystone_url => "http://${endpoint_address}:5000/v2.0",
    cinder_options => {
      'enable_backup' => true,
    },
    cache_backend => 'django.core.cache.backends.memcached.MemcachedCache',
    api_versions => {
      'identity' => '3',
      'image' => '2',
      'volume' => '2',
    },
    neutron_options => {
      'enable_lb' => true,
      'enable_firewall' => true,
      'enable_vpn' => true,
      'enable_router' => true,
    },
  }

}
