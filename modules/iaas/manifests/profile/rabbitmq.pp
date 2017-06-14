class iaas::profile::rabbitmq (
  $admin_interface = undef,
  $servers 	   = undef,
  $user     	   = undef,
  $password 	   = undef,
  $erlang 	   = undef,
  $node_hostname   = $::hostname,
  $package_gpg_key = undef,
) {
  $short_hostname_servers = regsubst($servers, '\..*','\1')
  class {'erlang': } ->
  package { 'erlang-base':
    ensure => 'latest',
  } ->
  class { '::rabbitmq':
    repos_ensure => false,
    service_ensure => 'running',
    port => 5672,
    delete_guest_user => true,
    config_cluster => true,
    cluster_nodes => $short_hostname_servers,
    erlang_cookie => $erlang,
    cluster_node_type => 'ram',
    wipe_db_on_cookie_change => true,
    cluster_partition_handling => 'pause_minority',
    config_variables => { 'tcp_listen_options' => "[binary, {packet, raw}, {reuseaddr, true}, {backlog, 128}, {nodelay, true}, {exit_on_close, false}, {keepalive, true}]" },
    environment_variables   => {
      'NODENAME'     => "rabbit@${node_hostname}",
    },
    manage_repos => true,
    package_gpg_key  => $package_gpg_key,
  } ->
  rabbitmq_user { $user:
    admin => true,
    password => $password,
  } ->
  rabbitmq_user_permissions { "${user}@/":
    configure_permission => '.*',
    write_permission => '.*',
    read_permission => '.*',
    provider => 'rabbitmqctl',
 } ->
 rabbitmq_policy { 'ha-all@/':
   pattern => '.*',
   priority => 0,
   applyto => 'all',
   definition => {
     'ha-mode' => 'all',
     'ha-sync-mode' => 'automatic',
   },
 }

  #@@haproxy::balancermember { "rabbitmq_${::fqdn}":
  #  listening_service => 'rabbitmq',
  #  server_names => $::hostname,
  #  ipaddresses => $::facts["ipaddress_${admin_interface}"],
  #  ports => '5672',
  #  options => 'check inter 2000 rise 2 fall 5',
  #}
}
