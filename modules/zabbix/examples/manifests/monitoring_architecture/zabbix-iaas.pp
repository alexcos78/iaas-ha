node 'zabbix-iaas.ocp.it'{
  
  include apt

  class { 'mysql::server':
                override_options => {
                        'mysqld'       => {
                        'bind_address' => '127.0.0.1',
                        },
                },
        }

  class { 'apache':
          mpm_module => 'prefork',
  }
  include apache::mod::php
  apache::listen { '80': }
  apache::listen { '443': }

  class { 'mysql::client': }
  
  $zabbix_version = '2.4'

  class { 'zabbix::repo':
                zabbix_version => $zabbix_version,
                manage_repo => true,
        }

  class { 'zabbix':
    
    # zabbix general configuration
    zabbix_version => $zabbix_version,
    zabbix_url => $fqdn,

    # zabbix::database configuration
    manage_database => true,
    database_type => 'mysql',
    database_host => 'localhost',
    database_name => 'zabbix',
    database_user => 'zabbix',
    database_password=> 'zabbix',
    zabbix_server => 'localhost',
    
    # zabbix::web configuration
    zabbix_web => 'localhost',
    zabbix_timezone => 'Europe/Rome',
    manage_vhost => true,
    apache_use_ssl => true,
  }

  class { 'zabbix::agent':
    server => '127.0.0.1',
    listenip => '127.0.0.1',
  }
}

