class iaas::role::monit_server(
     $database_password  = undef,
     $admin_interface	 = $iaas::params::admin_interface,
     $zabbix_version     = '2.4',
     $zabbix_key	 = 'FBABD5FB20255ECAB22EE194D13D58E479EA5ED4',
     $zabbix_key_source  = 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX',
  ) {
  class { 'iaas::profile::zabbix::server': 
     mysql_bind_address => '127.0.0.1',
     database_host 	=> '127.0.0.1',
     database_name 	=> 'zabbix',
     database_user	=> 'zabbix',
     database_password	=> $database_password,
     zabbix_server 	=> 'localhost',
     zabbix_web 	=> 'localhost',
     zabbix_timezone 	=> 'Europe/Rome',
     zabbix_server_ip 	=> '127.0.0.1',
     admin_interface    => $admin_interface,
     zabbix_version     => $zabbix_version, 
     zabbix_key         => $zabbix_key, 
     zabbix_key_source  => $zabbix_key_source, 
   }
}