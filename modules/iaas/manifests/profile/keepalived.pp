class iaas::profile::keepalived (
  $admin_interface 	   = undef,
  $public_interface 	   = undef,
  $vip_admin_address 	   = undef,
  $vip_main_address 	   = undef,
  $notification_email 	   = undef,
  $notification_email_from = undef,
  $smtp_server 		   = undef,
  $state 		   = 'BACKUP',
  $priority 		   = undef,
) {

  if $vip_admin_address == undef {
    $virtual_ipaddress = [{ 'ip'=>"${vip_main_address}", 'dev'=>"${public_interface}" }]
  } else {
    $virtual_ipaddress = [
                       { 'ip'=>"${vip_main_address}", 'dev'=>"${public_interface}" },
                       { 'ip'=>"${vip_admin_address}", 'dev'=>"${admin_interface}" }
                       ]
  }

sysctl::value { "net.ipv4.ip_nonlocal_bind": value => "1" }

include keepalived

  class { 'keepalived::global_defs':
    ensure                  => present,
    notification_email      => $notification_email,
    notification_email_from => $notification_email_from,
    smtp_server             => $smtp_server,
    smtp_connect_timeout    => '60',
    router_id		    => '51',
  } ->

  keepalived::vrrp::script {'chk_haproxy':
    interval          => '1',
    weight            => '3',
    script            => 'killall -0 haproxy',
  } ->

  keepalived::vrrp::instance { 'VI_1':
    interface         => $public_interface,
    state             => $state,
    virtual_router_id => '21',
    priority          => $priority,
    auth_type         => 'PASS',
    auth_pass         => '1111',
    virtual_ipaddress => $virtual_ipaddress,
    track_script      => 'chk_haproxy',
  } ->

  class { '::keepalived':
    service_restart => 'service keepalived reload',     # When using SysV Init
  }

}
