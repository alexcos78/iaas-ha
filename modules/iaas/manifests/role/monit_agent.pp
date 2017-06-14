class iaas::role::monit_agent(
     $zabbix_server_ip = undef,
     $admin_interface  = $iaas::params::admin_interface,
     $zabbix_version = '2.4',
     $zabbix_key         = 'FBABD5FB20255ECAB22EE194D13D58E479EA5ED4',
     $zabbix_key_source  = 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX',
  ) {
  class { 'iaas::profile::zabbix::agent': 
     zabbix_version => $zabbix_version,  
     zabbix_server_ip 	=> $zabbix_server_ip,
     admin_interface	=> $admin_interface,
     zabbix_key         => $zabbix_key,
     zabbix_key_source  => $zabbix_key_source,
  }
}