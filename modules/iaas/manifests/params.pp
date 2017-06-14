class iaas::params (

##Global variables
#Network
$public_interface 	= 'eth0',
$admin_interface	= 'eth0',
$data_interface 	= 'eth0',
#Node -- base.pp
$dns_servers		= ['DNS_SERVER1','DNS_SERVER2'],
$dns_searchdomain	= 'searchdomain.localhost',
#Enable only if $public_interface != $external_device1
$public_gateway		= undef,
$public_interf_method = 'dhcp',
#External devices
$external_device1 	= 'eth0',
$external_device2 	= undef,

##HOSTS
#VIP1
$main_hostname  = '<VIP_Hostname_public>', # VIP Hostname (public)
$main_address   = '<VIP_IP_public>', # The main virtual address pointing to the load-balancers
#VIP2
$admin_address  = undef, # The private virtual address pointing to the load-balancers
#Endpoints
$rhmk_hostnames = ['<HOSTNAME_SERVER1>', '<HOSTNAME_SERVER2>', '<HOSTNAME_SERVER3>'],
$rhmk_ips       = ['<IP_SERVER1>', '<IP_SERVER2>', '<IP_SERVER3>'],
#Controllers
$controller_ips         = ['<CONTROLLER1_IP>', '<CONTROLLER2_IP>'],
$controller_hostnames   = ['<CONTROLLER1_HOSTNAME>', '<CONTROLLER2_HOSTNAME>'],

##RabbitMQ
$rabbit_user     = 'openstack',
$rabbit_password = 'openstack',
$rabbit_package_gpg_key = 'https://www.rabbitmq.com/rabbitmq-release-signing-key.asc',

##CEPH
$ceph_fsid 		= 'f65809d3-7961-4cd7-b731-a9bc94bc6e9c',
# Uncomment if auth_type is different from 'cephx'
#$ceph_auth_type 	= 'cephx',
$ceph_mon_initmemb 	= '<CEPH_MONIM_1>,<CEPH_MONIM_2>,<CEPH_MONIM_3>',
$ceph_mon_host		= '<CEPH_MON_1>,<CEPH_MON_2>,<CEPH_MON_3>',
$ceph_osdpool_pgnum 	= '100',
$ceph_osdpool_pgpnum 	= '100',
$ceph_osdpool_size 	= '3',
$ceph_osdpool_minsize 	= '2',
$ceph_cluster_network 	= '10.10.98.0/24',
$ceph_public_network	= '10.10.98.0/24',
$ceph_journal_size 	= '5120',

##Openstack general
$os_verbose 	= false,
$os_debug 	= false,
$os_region	= 'regionOne',
$os_admin_token = '12345678901234567890',


##DB_params
#MysqlDB
$db_keystone_password 	= 'keystone',
$db_glance_password 	= 'glance',
$db_cinder_password	= 'cinder',
$db_nova_password  	= 'nova',
$db_neutron_password 	= 'neutron',
$db_heat_password 	= 'heat',
#MongoDB
$db_ceilometer_password = 'ceilometer',

##Neutron
$os_neutron_passwd 	= 'neutron',
$os_neutron_secret 	= 'neutron',
$os_neutron_corepl 	= 'ml2',
$os_neutron_servicepl 	= ['router', 'lbaas', 'vpnaas', 'firewall', 'metering'],

##Nova
$os_nova_passwd 	= 'nova',

##Ceilometer
$os_ceilometer_passwd 	= 'ceilometer',
$os_ceilometer_secret 	= 'ceilometer',

##Glance
$os_glance_passwd 	= 'glance',

##Cinder
$os_cinder_passwd 	= 'cinder',
$os_cinder_secret 	= '5e899071-df68-40d3-b0ea-6ec22b7c12a0',

##Heat
$os_heat_passwd 	= 'heat',
# https://bugs.launchpad.net/heat/+bug/1415887: "AES key must be either 16, 24, or 32 bytes long"
$os_heat_encrkey 	= '1234567890abcdef',

##Horizon
$os_horizon_secret 	= 'horizon',

##MTU VM
$mtu			= '1500',

){

#

}
