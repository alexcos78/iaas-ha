class iaas::profile::nova::compute (
  $admin_interface = undef,

  $neutron_password = 'neutron',
  $cinder_secret = undef,

  $region = undef,

#VIP1
  $endpoint_main = undef,
#VIP2
  $endpoint_admin = undef,

  $libvirt_type = 'qemu',
) {
  include iaas::profile::nova::common

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  package { 'sysfsutils': }

  sysctl::value { "net.ipv4.ip_forward": value => "1" }
  sysctl::value { "net.ipv4.conf.all.rp_filter": value => "0" }
  sysctl::value { "net.ipv4.conf.default.rp_filter": value => "0" }


  apt::pin { 'ceph':
    priority => '999',
    origin => 'download.ceph.com',
  } -> 
  class { '::nova::compute':
    enabled => true,
    vnc_enabled => true,
    vncserver_proxyclient_address => $::facts["ipaddress_${admin_interface}"],
    vncproxy_host => $endpoint_main,
    vnc_keymap => 'en-us',
  }

  class { '::nova::compute::neutron': }

  class { '::nova::compute::libvirt':
#    libvirt_virt_type => 'kvm',
    libvirt_virt_type => $libvirt_type,
    vncserver_listen => '0.0.0.0',
    migration_support => true,
  }

  class {'nova::compute::rbd':
    libvirt_rbd_user => 'cinder',
    libvirt_images_rbd_pool => 'vms',
    libvirt_rbd_secret_uuid => $cinder_secret,
    rbd_keyring => 'client.cinder',
    manage_ceph_client => false,
  }

  nova_config {
    'libvirt/libvirt_live_migration_flag': value => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST';
  }
}
