node 'zabbix-agent.ocp.it' {

  include apt

  $zabbix_version = '2.4'

  class { 'zabbix::repo':
           zabbix_version => $zabbix_version,
           manage_repo => true,
  }

  class { 'zabbix::agent':

          server => '<zabbix-iaas_floatingip>',
          listenip => '0.0.0.0',
          serveractive => '<zabbix-iaas_floatingip>:10051',
          zabbix_version => $zabbix_version,
          manage_firewall => true,
          manage_repo => true,
  }

}
