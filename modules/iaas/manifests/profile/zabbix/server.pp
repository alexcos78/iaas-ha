class iaas::profile::zabbix::server (
  $mysql_bind_address 	= undef,
  $database_host 	= undef,
  $database_name 	= undef,
  $database_user 	= undef,
  $database_password 	= undef,
  $zabbix_server 	= undef,
  $zabbix_web 		= undef,
  $zabbix_timezone 	= undef,
  $zabbix_server_ip 	= undef,
  $listenip 		= undef,
  $zabbix_version	= undef,
  $admin_interface	= undef,
  $zabbix_key		= undef,
  $zabbix_key_source	= undef,
){
  include apt

  class { 'mysql::server':
            override_options => {
              'mysqld'       => {
              'bind_address' => $mysql_bind_address,
             },
            },
        }

   class { 'apache':
           mpm_module => 'prefork',
           purge_configs => false,
           purge_vdir => false,
           purge_vhost_dir => false,
   }
   include apache::mod::php
   apache::listen { '80': }
   apache::listen { '443': }
   apache::listen { '8140': }
 
  class { 'mysql::client': }
  
  class { 'zabbix::repo':
            zabbix_version => $zabbix_version,
            manage_repo => false,
   }

  class { 'zabbix':

    # zabbix general configuration
    zabbix_version => $zabbix_version,
    zabbix_url => "zabbix.${fqdn}",  #controllare

    # zabbix::database configuration
    manage_database => true,
    database_type => 'mysql',
    database_host => $database_host,
    database_name => $database_name,
    database_user => $database_user,
    database_password=> $database_password,
    zabbix_server => $zabbix_server,

    # zabbix::web configuration
    zabbix_web => $zabbix_web,
    zabbix_timezone => $zabbix_timezone,
    manage_vhost => true,
    apache_use_ssl => true,
  }
 class { 'zabbix::agent':
         zabbix_server_ip => $zabbix_server_ip,
         admin_interface => $admin_interface,
	zabbix_version	=> $zabbix_version,
	zabbix_key	=> $zabbix_key,
	zabbix_key_source => $zabbix_key_source,
  }
}