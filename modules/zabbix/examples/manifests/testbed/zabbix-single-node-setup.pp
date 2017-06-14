node '<ZABBIX_SERVER_HOSTNAME>'{
  
  include apt

  class { 'mysql::server':
                override_options => {
                        'mysqld'       => {
                        'bind_address' => '127.0.0.1',
                        },
                },
        }

  #class { 'postgresql::server': }  

  class { 'apache':
          mpm_module => 'prefork',
          #default_mods        => false,
          #default_confd_files => false,
          purge_configs => false,
          purge_vdir => false,
          purge_vhost_dir => false,
  }
  include apache::mod::php
  apache::listen { '80': }
  apache::listen { '443': }

  class { 'mysql::client': }
  
  $zabbix_version = '2.2'

  class { 'zabbix::repo':
                zabbix_version => $zabbix_version,
                manage_repo => true,
        }

  class { 'zabbix':
    
    # zabbix general configuration
    zabbix_version => $zabbix_version,
    zabbix_url => "zabbix.${fqdn}",

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

