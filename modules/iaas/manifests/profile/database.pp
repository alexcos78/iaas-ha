class iaas::profile::database (
   $admin_interface		= $iaas::params::admin_interface,
   $percona_master 		= false,
   $root_password 		= undef,
   $mysql_cluster_servers	= ['hostname1', 'hostname2', 'hostname3'],
   $mysql_port 			= 3307, 
   $keystone_pwd 		= 'keystone',
   $glance_pwd 			= 'glance',
   $nova_pwd 			= 'nova',
   $cinder_pwd 			= 'cinder',
   $neutron_pwd 		= 'neutron',
   $heat_pwd 			= 'heat',
) {
	# INSTALLATION
   class{ 'percona':
    root_password	  => $root_password,
    mysql_cluster_servers => join($mysql_cluster_servers,','),
    mysql_port 		  => $mysql_port,
    master 		  => $percona_master,
    mysql_max_connections => '4000',
    wsrep_node_address 	  => getvar("::ipaddress_${admin_interface}") #$facts["ipaddress_${admin_interface}"],
   } ~>
   class { 'database-configure' :
     mysql_cluster_servers => $mysql_cluster_servers,
     keystone_pwd 		=> $keystone_pwd,
     glance_pwd		=> $glance_pwd,
     nova_pwd		=> $nova_pwd,
     cinder_pwd		=> $cinder_pwd,
     neutron_pwd		=> $neutron_pwd,
     heat_pwd		=> $heat_pwd,
   }
}
