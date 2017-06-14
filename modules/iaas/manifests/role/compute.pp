class iaas::role::compute (

##CEPH Secrets override
$ceph_secret_admin            = 'AQDgL/hUSC2kLBAAnWJaSiqJG+YMk+XV9sapnw==',
$ceph_secret_cinder           = 'AQAvxQpVKJ03KxAADFv78tedrAWZx1SoRdsQUA==',

##CEPH - no override
$ceph_fsid              = $iaas::params::ceph_fsid,
# Uncomment if auth_type is different from 'cephx'
#ceph_auth_type         = $iaas::params::ceph_auth_type,
$ceph_mon_initmembers   = $iaas::params::ceph_mon_initmemb,
$ceph_mon_host          = $iaas::params::ceph_mon_host,
$ceph_osdpool_pgnum     = $iaas::params::ceph_osdpool_pgnum,
$ceph_osdpool_pgpnum    = $iaas::params::ceph_osdpool_pgpnum,
$ceph_osdpool_size      = $iaas::params::ceph_osdpool_size,
$ceph_osdpool_minsize   = $iaas::params::ceph_osdpool_minsize,
$ceph_cluster_network   = $iaas::params::ceph_cluster_network,
$ceph_public_network    = $iaas::params::ceph_public_network,
$ceph_journal_size      = $iaas::params::ceph_journal_size,

#libvirt virt type: kvm or qemu
$libvirt_type = 'kvm',

) {

 ceph::key {
 'client.admin':
    secret => $ceph_secret_admin,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
    user => 'root',
    group => 'root',
    mode => '0550';

  'client.cinder':
    secret => $ceph_secret_cinder,
    cap_mon => 'allow r',
    cap_osd => 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images',
    user => 'nova',
    group => 'nova',
    mode => '0550';
 } 


  class { 'iaas::profile::neutron::client': 
        data_interface => $iaas::params::data_interface,
  } ->
  class { 'iaas::profile::nova::compute': 
        admin_interface 	=> $iaas::params::admin_interface,
        neutron_password 	=> $iaas::params::os_neutron_passwd,
        cinder_secret 		=> $iaas::params::os_cinder_secret,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
        libvirt_type 		=> $libvirt_type,
  } ->
#NEW-CEPH
  class {'ceph::profile::params':
        fsid                            => $ceph_fsid,
# Uncomment if auth_type is different from 'cephx'
        #authentication_type            => $iaas::params::ceph_auth_type,
        mon_initial_members             => $iaas::params::ceph_mon_initmemb,
        mon_host                        => $iaas::params::ceph_mon_host,
        osd_pool_default_pg_num         => $iaas::params::ceph_osdpool_pgnum,
        osd_pool_default_pgp_num        => $iaas::params::ceph_osdpool_pgpnum,
        osd_pool_default_size           => $iaas::params::ceph_osdpool_size,
        osd_pool_default_min_size       => $iaas::params::ceph_osdpool_minsize,
        cluster_network                 => $iaas::params::ceph_cluster_network,
        public_network                  => $iaas::params::ceph_public_network,
        osd_journal_size                => iaas::params::ceph_journal_size,
  } ->
  class { 'ceph::profile::base': } ->
  class { 'ceph::profile::client': } ->
  class { 'ceph::keys': } ->

  class { 'iaas::profile::ceilometer::compute': }
}
