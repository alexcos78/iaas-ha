class iaas::role::controller (

##CEPH Secrets override
$ceph_secret_glance  	= 'AQBgGdJUCPwjLRAARZ0KEaxewYcYHT3j5Gl5Cg==',
$ceph_secret_cinder	= 'AQAvxQpVKJ03KxAADFv78tedrAWZx1SoRdsQUA==',
$ceph_secret_cinderbkup = 'AQBKvuVUMHvaGhAADT6nvBv9LFs7dqpB8Kis0Q==',

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

##ADMIN credentails - override
#$os_admin_token 	= '12345678901234567890',
$os_admin_token 	= $iaas::params::os_admin_token,
$os_admin_email		= 'admin@mail',
$os_admin_passwd 	= '<ADMIN_PASSWORD>',
$os_admin_tenant 	= 'admin',

##Tenants&Users - override
$os_tenants  =  {'test'=> { description => 'OCP in HA'}},
$os_users    =  {'guest' => {password => 'pippo', tenant => 'test', email => 'alessandro.costantini@cnaf.infn.it' }},

##Neutron networks - override
#Network1
$neutron_ext1_network = '10.10.98.0/24',
$neutron_ext1_gateway = '10.10.98.1',
$neutron_ext1_ipstart = '10.10.98.121',
$neutron_ext1_ipend   = '10.10.98.125',
#$neutron_private1 	   = '10.0.1.0/24',
#Network2
$neutron_ext2_network = undef,
$neutron_ext2_gateway = undef,
$neutron_ext2_ipstart = undef,
$neutron_ext2_ipend   = undef,
#$neutron_private2         = undef,

){
 ceph::key {
  'client.glance':
    secret 	=> $ceph_secret_glance,
    cap_mon 	=> 'allow r', 
    cap_osd 	=> 'allow class-read object_prefix rbd_children, allow rwx pool=images',
    user 	=> 'glance',
    group 	=> 'glance',
    mode 	=> '0550';

  'client.cinder':
    secret 	=> $ceph_secret_cinder,
    cap_mon 	=> 'allow r', 
    cap_osd 	=> 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images',
    user 	=> 'cinder',
    group 	=> 'cinder',
    mode 	=> '0550';

  'client.cinder-backup':
    secret 	=> $ceph_secret_cinderbkup,
    cap_mon 	=> 'allow r', 
    cap_osd 	=> 'allow class-read object_prefix rbd_children, allow rwx pool=backups',
    user 	=> 'cinder',
    group 	=> 'cinder',
    mode 	=> '0550', 
 }

# Exclude openstack-dashboard-ubuntu-theme package
 apt::pin { 'openstack-dashboard-ubuntu-theme':
    packages => 'openstack-dashboard-ubuntu-theme',
    release => 'openstack-dashboard-ubuntu-theme',
    component => 'main',
    priority => -1
 } ->

# Classes
  class { 'iaas::profile::database-client': } ->
  class { 'iaas::profile::keystone': 
	tenants 		=> $os_tenants,
        users 			=> $os_users,
        admin_token 		=> $os_admin_token,
        admin_email 		=> $os_admin_email,
        admin_password 		=> $os_admin_passwd,
        admin_tenant 		=> $os_admin_tenant,
        verbose 		=> $iaas::params::os_verbose,
        debug 			=> $iaas::params::os_debug,
        public_interface 	=> $iaas::params::public_interface,
        admin_interface 	=> $iaas::params::admin_interface,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
        rhosts 			=> $iaas::params::rhmk_ips,
        rabbitmq_user 		=> $iaas::params::rabbit_user,
        rabbitmq_password 	=> $iaas::params::rabbit_password,
  } ~> 
  class { 'iaas::profile::glance': 
        password 		=> $iaas::params::os_glance_passwd, 
        public_interface 	=> $iaas::params::public_interface,
        admin_interface 	=> $iaas::params::admin_interface,
        verbose 		=> $iaas::params::os_verbose,
        debug 			=> $iaas::params::os_debug,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
        rhosts 			=> $iaas::params::rhmk_ips,
        rabbitmq_user 		=> $iaas::params::rabbit_user,
        rabbitmq_password 	=> $iaas::params::rabbit_password,
  } ->
##NEW-CEPH
  class {'ceph::profile::params':
        fsid 				=> $ceph_fsid,
# Uncomment if auth_type is different from 'cephx'
        #authentication_type 		=> $iaas::params::ceph_auth_type,
        mon_initial_members 		=> $iaas::params::ceph_mon_initmemb,
        mon_host 			=> $iaas::params::ceph_mon_host,
        osd_pool_default_pg_num 	=> $iaas::params::ceph_osdpool_pgnum,
        osd_pool_default_pgp_num 	=> $iaas::params::ceph_osdpool_pgpnum,
        osd_pool_default_size 		=> $iaas::params::ceph_osdpool_size,
        osd_pool_default_min_size 	=> $iaas::params::ceph_osdpool_minsize,
        cluster_network 		=> $iaas::params::ceph_cluster_network,
        public_network 			=> $iaas::params::ceph_public_network,
        osd_journal_size 		=> iaas::params::ceph_journal_size,
  } ->
  class { 'ceph::profile::base': } ->
  class { 'ceph::profile::client': } ->
  class { 'ceph::keys': } ->
#
  class { 'iaas::profile::cinder': 
        password                => $iaas::params::os_cinder_passwd,
        secret                  => $iaas::params::os_cinder_secret,
        public_interface        => $iaas::params::public_interface,
        admin_interface         => $iaas::params::admin_interface,
        verbose                 => $iaas::params::os_verbose,
        debug                   => $iaas::params::os_debug,
        region                  => $iaas::params::os_region,
        endpoint_main           => $iaas::params::main_address,
        endpoint_admin          => $iaas::params::admin_address,
        rhosts                  => $iaas::params::rhmk_ips,
        rabbitmq_user           => $iaas::params::rabbit_user,
        rabbitmq_password       => $iaas::params::rabbit_password,
  } ->
  class { 'iaas::profile::nova::controller': 
        public_interface 	=> $iaas::params::public_interface,
        admin_interface 	=> $iaas::params::admin_interface,
        password 		=> $iaas::params::os_nova_passwd,
        neutron_secret 		=> $iaas::params::os_neutron_secret,
        neutron_password 	=> $iaas::params::os_neutron_passwd,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
  } ->
  class { 'iaas::profile::neutron::server': 
        public_interface 	=> $iaas::params::public_interface,
        admin_interface 	=> $iaas::params::admin_interface,
        neutron_password 	=> $iaas::params::os_neutron_passwd,
        nova_password 		=> $iaas::params::os_nova_passwd,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
  } ->
  class { 'iaas::profile::ceilometer::controller': 
        coordination_ip 	=> $iaas::params::rhmk_ips,
        public_interface 	=> $iaas::params::public_interface,
        admin_interface 	=> $iaas::params::admin_interface,
        password 		=> $iaas::params::os_ceilometer_passwd,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
  } ->
  class { 'iaas::profile::heat': 
        password 		=> $iaas::params::os_heat_passwd,
        encryption_key 		=> $iaas::params::os_heat_encrkey,
        public_interface        => $iaas::params::public_interface,
        admin_interface         => $iaas::params::admin_interface,
        verbose                 => $iaas::params::os_verbose,
        debug                   => $iaas::params::os_debug,
        region                  => $iaas::params::os_region,
        endpoint_main           => $iaas::params::main_address,
        endpoint_admin          => $iaas::params::admin_address,
        rhosts                  => $iaas::params::rhmk_ips,
        rabbitmq_user           => $iaas::params::rabbit_user,
        rabbitmq_password       => $iaas::params::rabbit_password,
  } ->
  class { 'iaas::profile::horizon': 
        secret			=> $iaas::params::os_horizon_secret,
        endpoint_address 	=> $iaas::params::main_hostname,
        endpoint_servers 	=> $iaas::params::rhmk_hostnames,
        public_interface	=> $iaas::params::public_interface,
        admin_interface 	=> $iaas::params::admin_interface,
  } ->
  class { 'iaas::setup::sharednetwork': 
        external_network1 	=> $neutron_ext1_network,
        gateway1  		=> $neutron_ext1_gateway,
        start_ip1 		=> $neutron_ext1_ipstart,
        end_ip1   		=> $neutron_ext1_ipend,
#        private_network1 	=> $neutron_private1,
        external_network2 	=> $neutron_ext2_network,
        gateway2  		=> $neutron_ext2_gateway,
        start_ip2 		=> $neutron_ext2_ipstart,
        end_ip2   		=> $neutron_ext2_ipend,
#        private_network2 	=> $neutron_private2,
        dns  			=> $iaas::params::dns_servers,
  } ->
  class { 'iaas::profile::auth_file': 
        admin_password 		=> $os_admin_passwd,
        admin_tenant 		=> $os_admin_tenant,
#        region 			=> $iaas::params::os_region,
#        endpoint_hostname 	=> $iaas::params::main_hostname,
  }
}
