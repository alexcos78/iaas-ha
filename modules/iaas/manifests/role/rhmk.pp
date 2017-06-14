# == Class iaas::role::rhmk
#
#  Ruolo RHMK (RabbitMQ, HAproxy, MySql/Mongodb, Keepalived).
#  https://support.ba.infn.it/redmine/projects/automaticocp/wiki/Keepalived_HAProxy_MySQLPercona_e_RabbitMQ_in_HA_su_testbed_Puppet
#
# === Parameters:
#
# [*percona_master*]
#  Default a false. Da settare a true per avviare percona in bootstrap mode.
# [*mongo_master*]
#
class iaas::role::rhmk(
    # GLOBAL
    $main_address		= $iaas::params::main_address,
    $admin_address		= $iaas::params::admin_address,
    $public_interface		= $iaas::params::public_interface,
    $admin_interface		= $iaas::params::admin_interface,
    $hostnames			= $iaas::params::rhmk_hostnames, # ['<hostname1>','<hostnameN>'],
    $ips			= $iaas::params::rhmk_ips, # ['<ip1>','<ipN>'],
    $dns_servers		= $iaas::params::dns_servers, 
    $dns_searchdomain		= $iaas::params::dns_searchdomain,
    # MYSQL
    $percona_master 		= false,
    $mysql_root_pwd		= undef,
    $keystone_pwd		= $iaas::params::db_keystone_password, #'keystone',
    $glance_pwd			= $iaas::params::db_glance_password, #'glance',
    $nova_pwd			= $iaas::params::db_nova_password, #'nova',
    $cinder_pwd			= $iaas::params::db_cinder_password, #'cinder',
    $neutron_pwd		= $iaas::params::db_neutron_password, #'neutron',
    $heat_pwd			= $iaas::params::db_heat_password, #'heat',
    # MONGODB
    $mongo_master		= false,
    $mongo_bootstrap 		= false,
    $mongo_key			= 'Uf+8s0LbxIxNrbyEC1kw',
    $mongo_password		= undef,
    $ceilometer_pwd		= $iaas::params::db_ceilometer_password, #'ceilometer',
    # KEEPALIVED
    $keepalived_priority 	= 100,
    $keepalived_state 		= 'BACKUP',
    $keepalived_notification_mail	= 'account@domain1',
    $keepalived_notification_mail_from  = 'noreply-keepalived-ocpops1@cnaf.infn.it',
    $keepalived_smtp_server		= 'smtp.server1',
    # HAPROXY
    $haproxy_controller_hosts 	= $iaas::params::controller_hostnames, #['<hostname1>','<hostnameN>'],
    $haproxy_controller_ips 	= $iaas::params::controller_ips, #['<ip1>','<ipN>'],
    $haproxy_stats_enabled	= "true",
    $haproxy_stats_ports	= [1936],
    $haproxy_stats_refresh	= "30s",
    $haproxy_stats_login	= "stats",
    $haproxy_stats_password	= "stats",
    $haproxy_stats_uri		= "/",
    # RABBITMQ
    $rabbit_hostname 		= $hostname,
    $rabbit_user                = $iaas::params::rabbit_user, #'openstack',
    $rabbit_password            = $iaas::params::rabbit_password, #'openstack',
    $rabbit_erlang              = 'JTZEOFFHPRJOTLUWEFQR',
    $rabbit_package_gpg_key     = $iaas::params::rabbit_package_gpg_key,
    # ZOOKEEPER
    $zookeeper_id 		= undef,
  ) {

  class { 'iaas::profile::database':
    percona_master  	  => $percona_master,
    root_password   	  => $mysql_root_pwd,
    mysql_cluster_servers => $ips,
    keystone_pwd	  => $keystone_pwd,
    glance_pwd	 	  => $glance_pwd,
    nova_pwd		  => $nova_pwd,
    cinder_pwd		  => $cinder_pwd,
    neutron_pwd	          => $neutron_pwd,
    heat_pwd		  => $heat_pwd,
  } 
  class { 'iaas::profile::haproxy':
    percona_hosts      => $hostnames,
    percona_ips        => $ips,
    controller_hosts   => $haproxy_controller_hosts,
    controller_ips     => $haproxy_controller_ips,
    main_address       => $main_address,
    admin_address      => $admin_address,
    stats_enabled      => $haproxy_stats_enabled,
    stats_ports	       => $haproxy_stats_ports,
    stats_refresh      => $haproxy_stats_refresh,
    stats_login        => $haproxy_stats_login,
    stats_password     => $haproxy_stats_password,
    stats_uri          => $haproxy_stats_uri,
  }
  class { 'iaas::profile::keepalived':
    admin_interface    	    => $admin_interface,
    public_interface   	    => $public_interface,
    vip_admin_address       => $admin_address,
    vip_main_address        => $main_address,
    state    	            => $keepalived_state,
    priority 	            => $keepalived_priority,
    notification_email      => $keepalived_notification_mail,
    notification_email_from => $keepalived_notification_mail_from,
    smtp_server 	    => $keepalived_smtp_server,
  }
  class { 'iaas::profile::rabbitmq': 
    admin_interface => $admin_interface,
    node_hostname   => $rabbit_hostname,
    servers	    => $hostnames,
    user            => $rabbit_user,
    password        => $rabbit_password,
    erlang          => $rabbit_erlang,
    package_gpg_key => $rabbit_package_gpg_key,
  } 
  class { 'iaas::profile::zookeeper':
    admin_interface 	      => $admin_interface,
    servers                   => $hostnames,
    zookeeper_max_connections => 128,
    zookeeper_id  	      => $zookeeper_id
  }
  class { 'iaas::profile::mongodb':
    admin_interface => $admin_interface,
    hosts           => $hostnames,
    master          => $mongo_master,
    bootstrap       => $mongo_bootstrap,
    key             => $mongo_key,
    password        => $mongo_password,
    mongouser       => 'ceilometer',
    mongopasswd     => $ceilometer_pwd,
  } 
}
