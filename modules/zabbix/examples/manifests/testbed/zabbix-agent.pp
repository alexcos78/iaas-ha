node '<ZABBIX_AGENT_HOSTNAME>' {

  include apt

  $zabbix_version = '2.2'

  class { 'zabbix::repo':
           zabbix_version => $zabbix_version,
           manage_repo => true,
  }

  class { 'zabbix::agent':

          server => '<zabbix_server_ip>',
          listenip => $ipaddress_eth0,
          serveractive => '<zabbix_server_ip>:10051',
          zabbix_version => $zabbix_version,
          manage_repo => true,
  }
}
