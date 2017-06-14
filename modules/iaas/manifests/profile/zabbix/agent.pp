class iaas::profile::zabbix::agent (
  $zabbix_server_ip = undef,
  $admin_interface  = undef,
  $zabbix_version = undef,
  $zabbix_key = undef,
  $zabbix_key_source = undef,
){ 
   include apt
   apt::source { 'zabbix':
     location   => "http://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu/",
     repos      => 'main',
     key        => $zabbix_key, 
     key_source => $zabbix_key_source,
   }->
   class { '::zabbix::agent':
          server => $zabbix_server_ip,
          listenip => getvar("::ipaddress_${admin_interface}"),
          serveractive => "${zabbix_server_ip}:10051",
          manage_repo => false,
          zabbix_version => $zabbix_version,
  }
}