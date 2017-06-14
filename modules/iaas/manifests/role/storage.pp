class iaas::role::storage (

##CEPH Secrets - override
$ceph_secret_admin            	= 'AQDgL/hUSC2kLBAAnWJaSiqJG+YMk+XV9sapnw==',
$ceph_secret_bootstrap     	= 'AQDlL/hUUCpdFBAAZeo6mKj4yeKPmVKfUY5awA==',
$ceph_secret_glance           	= 'AQBgGdJUCPwjLRAARZ0KEaxewYcYHT3j5Gl5Cg==',
$ceph_secret_cinder           	= 'AQAvxQpVKJ03KxAADFv78tedrAWZx1SoRdsQUA==',
$ceph_secret_cinderbkup     	= 'AQBKvuVUMHvaGhAADT6nvBv9LFs7dqpB8Kis0Q==',
$ceph_bootstrap_mdskey		= 'AQBxkvVU4F+VDBAArxUf+8s0LbxIxNrbyEC1kw==',
$ceph_mon_key			= 'AQApksZUIJhXJxAAEHVW/dbL1OeLA7Om++zdVw==',
#$ceph_secret_radosgw            = 'AQCbGddWJyqjHBAAomrJkvccCHsWaNcIif65mg==',
$ceph_secret_radosgw_gateway    = 'AQBNN9dWbU3SORAAERedNbXc0gxm0edAfayf2w==',

##OSD+POOL configuration
$osd_configure			= true,

##CEPH - no override
$ceph_fsid 		= $iaas::params::ceph_fsid,
# Uncomment if auth_type is different from 'cephx'
#$ceph_auth_type 	= $iaas::params::ceph_auth_type,
$ceph_mon_initmembers 	= $iaas::params::ceph_mon_initmemb,
$ceph_mon_host 		= $iaas::params::ceph_mon_host,
$ceph_osdpool_pgnum 	= $iaas::params::ceph_osdpool_pgnum,
$ceph_osdpool_pgpnum 	= $iaas::params::ceph_osdpool_pgpnum,
$ceph_osdpool_size 	= $iaas::params::ceph_osdpool_size, 
$ceph_osdpool_minsize 	= $iaas::params::ceph_osdpool_minsize,
$ceph_cluster_network 	= $iaas::params::ceph_cluster_network,
$ceph_public_network 	= $iaas::params::ceph_public_network,
$ceph_journal_size 	= $iaas::params::ceph_journal_size,

##CEPH - override
$ceph_pool =  {'images'             => { pg_num => '8'},
               'volumes'            => { pg_num => '64'},
               'vms'                => { pg_num => '16'},
               'backups'            => { pg_num => '32'}},

##CEPH WITH RADOSGW ENABLED - override
#$ceph_pool =  {'images'             => { pg_num => '8'},
#               'volumes'            => { pg_num => '64'},
#               'vms'                => { pg_num => '16'},
#               'backups'            => { pg_num => '32'},
#               '.rgw.root'          => { pg_num => '4'},
#               '.rgw.control'       => { pg_num => '4'},
#               '.rgw.gc'            => { pg_num => '4'},
#               '.rgw.buckets'       => { pg_num => '32'},
#               '.rgw.buckets.index' => { pg_num => '4'},
#               '.rgw.buckets.extra' => { pg_num => '4'},
#               '.log'               => { pg_num => '4'},
#               '.intent-log'        => { pg_num => '4'},
#               '.usage'             => { pg_num => '4'},
#               '.users'             => { pg_num => '4'},
#               '.users.email'       => { pg_num => '4'},
#               '.users.swift'       => { pg_num => '4'},
#               '.users.uid'         => { pg_num => '4'}}

$ceph_osd  =  {'/dev/vdb'=> { journal => '/osd1'},                       
               '/dev/vdc'=> { journal => '/osd2'}},

##RADOSGW
$rgw_enable = false,

) {

# Ceph
##OSD

  if $osd_configure {
    create_resources( ceph::osd, $ceph_osd )

##POOL
    create_resources( ceph::pool, $ceph_pool )
  }

##KEY
  ceph::key {
   'client.admin':
     user => 'ceph',
     group => 'ceph',
     secret => $ceph_secret_admin,
     cap_mon => 'allow *',
     cap_osd => 'allow *',
     cap_mds => 'allow',
     inject => 'true',
     inject_as_id => 'mon.',
     inject_keyring => "/var/lib/ceph/mon/ceph-$::hostname/keyring";

   'client.bootstrap-osd':
     user => 'ceph',
     group => 'ceph',
     secret => $ceph_secret_bootstrap,
     cap_mon => 'allow profile bootstrap-osd',
     keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
     inject => 'true',
     inject_as_id => 'mon.',
     inject_keyring => "/var/lib/ceph/mon/ceph-$::hostname/keyring";

   'client.glance':
     user => 'ceph',
     group => 'ceph',
     secret => $ceph_secret_glance,
     cap_mon => 'allow r',
     cap_osd => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
     inject => 'true',
     inject_as_id => 'mon.',
     inject_keyring => "/var/lib/ceph/mon/ceph-$::hostname/keyring";

   'client.cinder':
     user => 'ceph',
     group => 'ceph',
     secret => $ceph_secret_cinder,
     cap_mon => 'allow r',
     cap_osd => 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images',
     inject => 'true',
     inject_as_id => 'mon.',
     inject_keyring => "/var/lib/ceph/mon/ceph-$::hostname/keyring";
 
   'client.cinder-backup':
     user => 'ceph',
     group => 'ceph',
     secret => $ceph_secret_cinderbkup,
     cap_mon => 'allow r',
     cap_osd => 'allow class-read object_prefix rbd_children, allow rwx pool=backups',
     inject => 'true',
     inject_as_id => 'mon.',
     inject_keyring => "/var/lib/ceph/mon/ceph-$::hostname/keyring";

   'client.radosgw.gateway':
     user => 'ceph',
     group => 'ceph',
     secret => $ceph_secret_radosgw_gateway,
     cap_mon => 'allow rwx',
     cap_osd => 'allow rwx',
     inject => 'true',
     inject_as_id => 'mon.',
     inject_keyring => "/var/lib/ceph/mon/ceph-$::hostname/keyring",
  } 



# Classes
# CEPH
  class {'ceph::profile::params':
     fsid                       => $iaas::params::ceph_fsid,
# Uncomment if auth_type is different from 'cephx'
#     authentication_type        => $iaas::params::ceph_auth_type,
     mon_initial_members        => $iaas::params::ceph_mon_initmemb,
     mon_host                   => $iaas::params::ceph_mon_host,
     osd_pool_default_pg_num    => $iaas::params::ceph_osdpool_pgnum,
     osd_pool_default_pgp_num   => $iaas::params::ceph_osdpool_pgpnum,
     osd_pool_default_size      => $iaas::params::ceph_osdpool_size,
     osd_pool_default_min_size  => $iaas::params::ceph_osdpool_minsize,
     cluster_network            => $iaas::params::ceph_cluster_network,
     public_network             => $iaas::params::ceph_public_network,
     mon_key                    => $ceph_mon_key,
     osd_journal_size           => $iaas::params::ceph_journal_size,
     enable_rgw			=> $rgw_enable,
     fastcgi			=> $rgw_enable,
  } ->
  class { 'iaas::profile::fastcgi':
    enable_fastcgi => $rgw_enable,
  } ->
  class { 'ceph::profile::base': } ->
  class { 'ceph::profile::mon': } ->
  class { 'ceph::keys': } 
  class { 'iaas::profile::radosgw': 
   enable_rgw => $rgw_enable,
#   secret_user => $ceph_secret_radosgw, 
  } 
 
}
