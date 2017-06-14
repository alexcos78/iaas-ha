## t_hostname         => $hostname,ZABBIX
#a zabbix node variables
$zabbix_server_ip = '192.168.0.11'
$zabbix_version  = '2.4'
$zabbix_db_pwd    = undef
$zabbix_install   = true
$zabbix_key       = 'FBABD5FB20255ECAB22EE194D13D58E479EA5ED4'
$zabbix_key_source  = 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'

# NODE DEFINITION
# ===============

## RHMK NODES

$mysql_root_pwd		= undef
$mongo_key		= undef #'Uf+8s0LbxIxNrbyEC1kw'
$mongo_password		= undef
$haproxy_stats_enabled	= "true"
$haproxy_stats_ports	= [1936]
$haproxy_stats_refresh	= "30s"
$haproxy_stats_login	= "stats"
$haproxy_stats_password	= "stats"
$haproxy_stats_uri	= "/"
$rabbit_erlang		= 'JTZEOFFHPRJOTLUWEFQR'
$rabbit_package_gpg_key = "https://www.rabbitmq.com/rabbitmq-release-signing-key.asc"

#node '<RHMK_HOSTNAME1>' {
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::rhmk':
#       percona_master		=> true, # percona_master to be true only if renewing the cluster
#	mysql_root_pwd		=> $mysql_root_pwd,	
#       mongo_master    	=> true,
#       mongo_bootstrap 	=> true,  # mongo_bootstrap to be commented during replica sets cluster configuration
#	mongo_key		=> $mongo_key, 
#	mongo_password		=> $mongo_password,
#       keepalived_state 	=> 'MASTER',
#       keepalived_priority 	=> 102,
#	haproxy_stats_enabled   => $haproxy_stats_enabled,
#	haproxy_stats_ports     => $haproxy_stats_ports,
#	haproxy_stats_refresh   => $haproxy_stats_refresh,
#	haproxy_stats_login	=> $haproxy_stats_login,
#	haproxy_stats_password	=> $haproxy_stats_password,
#	haproxy_stats_uri	=> $haproxy_stats_uri,
#	rabbit_erlang		=> $rabbit_erlang,
#       rabbit_hostname 	=> $hostname,
#	rabbit_package_gpg_key  => $rabbit_package_gpg_key,
##set zookeeper index (1,..,N)
#       zookeeper_id => '1',
#  }
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip, 
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,
#       }
#  }
#}
#
#node '<RHMK_HOSTNAME2>' {
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::rhmk':
#	mysql_root_pwd          => $mysql_root_pwd,
#	mongo_key		=> $mongo_key, 
#	mongo_password		=> $mongo_password,
#       keepalived_state 	=> 'BACKUP',
#       keepalived_priority 	=> 101,
#	haproxy_stats_enabled   => $haproxy_stats_enabled,
#	haproxy_stats_ports     => $haproxy_stats_ports,
#	haproxy_stats_refresh   => $haproxy_stats_refresh,
#	haproxy_stats_login	=> $haproxy_stats_login,
#	haproxy_stats_password	=> $haproxy_stats_password,
#	haproxy_stats_uri	=> $haproxy_stats_uri,
#	rabbit_erlang		=> $rabbit_erlang,
#       rabbit_hostname 	=> $hostname,
#	rabbit_package_gpg_key  => $rabbit_package_gpg_key,
##set zookeeper index (1,..,N)
#       zookeeper_id => '2',
#  }
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip,  
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,

#	}
#  }
#}
#
#node '<RHMK_HOSTNAME3>' {
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::rhmk':
#	mysql_root_pwd          => $mysql_root_pwd,
#	mongo_key		=> $mongo_key, 
#	mongo_password		=> $mongo_password,
#       keepalived_state 	=> 'MASTER',
#       keepalived_priority 	=> 100,
#	haproxy_stats_enabled   => $haproxy_stats_enabled,
#	haproxy_stats_ports     => $haproxy_stats_ports,
#	haproxy_stats_refresh   => $haproxy_stats_refresh,
#	haproxy_stats_login	=> $haproxy_stats_login,
#	haproxy_stats_password	=> $haproxy_stats_password,
#	haproxy_stats_uri	=> $haproxy_stats_uri,
#	rabbit_erlang		=> $rabbit_erlang,
#       rabbit_hostname 	=> $hostname,
#	rabbit_package_gpg_key  => $rabbit_package_gpg_key,
##set zookeeper index (1,..,N)
#       zookeeper_id => '3',
#  }
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip,  
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,
#	}
#  }
#}
#

## CEPH STORAGE NODES

$ceph_secret_admin      = 'AQDgL/hUSC2kLBAAnWJaSiqJG+YMk+XV9sapnw=='
$ceph_secret_bootstrap  = 'AQDlL/hUUCpdFBAAZeo6mKj4yeKPmVKfUY5awA=='
$ceph_secret_glance     = 'AQBgGdJUCPwjLRAARZ0KEaxewYcYHT3j5Gl5Cg=='
$ceph_secret_cinder     = 'AQAvxQpVKJ03KxAADFv78tedrAWZx1SoRdsQUA=='
$ceph_secret_cinderbkup = 'AQBKvuVUMHvaGhAADT6nvBv9LFs7dqpB8Kis0Q=='
$ceph_bootstrap_mdskey  = 'AQBxkvVU4F+VDBAArxUf+8s0LbxIxNrbyEC1kw=='
$ceph_mon_key           = 'AQApksZUIJhXJxAAEHVW/dbL1OeLA7Om++zdVw=='

#node '<storage_hostname>' {
#
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::storage':
#	ceph_secret_admin	=> $ceph_secret_admin,
#	ceph_secret_bootstrap 	=> $ceph_secret_bootstrap, 
#	ceph_secret_glance     	=> $ceph_secret_glance,
#	ceph_secret_cinder     	=> $ceph_secret_cinder,
#	ceph_secret_cinderbkup 	=> $ceph_secret_cinderbkup,
#	ceph_bootstrap_mdskey  	=> $ceph_bootstrap_mdskey,
#	ceph_mon_key           	=> $ceph_mon_key,
#	osd_configure          	=> true,
#	ceph_pool =>  { 'images'  => { pg_num => '128'},
#               	'volumes' => { pg_num => '128'},
#               	'vms'     => { pg_num => '128'},
#               	'backups' => { pg_num => '128'}},
#	ceph_osd  =>  { '/dev/vdb'=> { journal => '/osd1'},    
#               	'/dev/vdc'=> { journal => '/osd2'}},
#  }
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip,   
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,
#       }
#  }
#
#}

## CONTROLLER NODE(s)
#node '<CONTROLLER_HOSTNAME>' {
#
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::controller':
#	ceph_secret_glance     => $ceph_secret_glance, 
#       ceph_secret_cinder     => $ceph_secret_cinder,
#       ceph_secret_cinderbkup => $ceph_secret_cinderbkup,
#	os_admin_token         => '12345678901234567890',
#	os_admin_email         => 'admin@mail',
#	os_admin_passwd        => '<ADMIN_PASSWORD>',
#	os_admin_tenant        => 'admin',
#	os_tenants  		=> {'test'=> { description => 'OCP in HA'}},
#	os_users    		=> {'guest' => {password => 'pippo', tenant => 'test', email => 'alessandro.costantini@cnaf.infn.it' }},
#	##Neutron networks - override
#	#Network1
#	neutron_ext1_network 	=> '10.10.98.0/24',
#	neutron_ext1_gateway 	=> '10.10.98.1',
#	neutron_ext1_ipstart 	=> '10.10.98.121',
#	neutron_ext1_ipend   	=> '10.10.98.125',
#	#Network2
#	neutron_ext2_network 	=> undef,
#	neutron_ext2_gateway 	=> undef,
#	neutron_ext2_ipstart 	=> undef,
#	neutron_ext2_ipend   	=> undef,
#  }
#
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip,   
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,
#       }
#  }
#
#}


##NETWORK NODE(s)
#node '<NETWORK_HOSTNAME>' {
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::network':
#	##Network1 - external
#	neutron_ext1_network => '10.10.98.0/24',
#	neutron_ext1_gateway => '10.10.98.1',
#	##Network2 - external
#	neutron_ext2_network => undef,
#	neutron_ext2_gateway => undef,
#	
#	##MTU VM
#	mtu 		      => '1438',
#  }
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip,   
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,
#       }
#  }
#}

##COMPUTE NODE(s)
#node '<COMPUTE_HOSTNAME>' {
#  include 'iaas::params'
#  include 'iaas::role::iaasbase'
#  class {'iaas::role::compute':
#	##CEPH Secrets override
#	ceph_secret_admin    	=> $ceph_secret_admin,
#	ceph_secret_cinder   	=> $ceph_secret_cinder,
#  	libvirt_type		=> 'kvm',
#  }
#
#  if $zabbix_install {
#       class {'iaas::role::monit_agent':
#         zabbix_version   => $zabbix_version,
#         zabbix_server_ip => $zabbix_server_ip,   
#	  zabbix_key 	   => $zabbix_key,
#	  zabbix_key_source => $zabbix_key_source,
#       }
#  }
#
#}

#node '<ZABBIX_SERVER_HOSTNAME>'{
# if $zabbix_install {
#   include 'iaas::params'
#   include 'iaas::role::iaasbase'
#   class {'iaas::role::monit_server':
#       database_password 	=> $zabbix_db_pwd,
#       zabbix_version          => $zabbix_version  
#	zabbix_key 	   => $zabbix_key,
#	zabbix_key_source => $zabbix_key_source,
#   }
# }
#}
