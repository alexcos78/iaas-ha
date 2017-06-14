class iaas::profile::database-configure (
  $mysql_cluster_servers,
  $keystone_pwd,
  $glance_pwd,
  $nova_pwd,
  $cinder_pwd,
  $neutron_pwd,
  $heat_pwd, 
){

   exec { 'drop anonymous users on specific host':
    command => "mysql --defaults-extra-file=/root/.my.cnf -u root -e \"GRANT USAGE ON *.* TO \'\'@\'$::hostname\'; DROP USER \'\'@\'$::hostname\';\"",
    path    => [ '/bin', '/usr/bin' ],
   } ->
   exec { 'drop anonymous users on localhost':
    command => "mysql --defaults-extra-file=/root/.my.cnf -u root -e \"GRANT USAGE ON *.* TO \'\'@\'localhost\'; DROP USER \'\'@\'localhost\';\"",
    path    => [ '/bin', '/usr/bin' ],
   }   

	# DB CREATION
  $databases = ['keystone', 'glance', 'nova', 'cinder', 'neutron', 'heat','nova_api']

  mysql_database { $databases:
     ensure  => 'present',
     charset => 'utf8',
     collate => 'utf8_general_ci',
  }

	# DB USER
  $user_keystone = regsubst($mysql_cluster_servers, '^', 'keystone@')
  $user_glance 	 = regsubst($mysql_cluster_servers, '^', 'glance@')
  $user_nova 	 = regsubst($mysql_cluster_servers, '^', 'nova@')
  $user_cinder 	 = regsubst($mysql_cluster_servers, '^', 'cinder@')
  $user_neutron  = regsubst($mysql_cluster_servers, '^', 'neutron@')
  $user_heat 	 = regsubst($mysql_cluster_servers, '^', 'heat@')

  mysql_user { $user_keystone:
    ensure 	  => 'present',
    password_hash => mysql_password($keystone_pwd),
  }
  mysql_user { $user_glance:
    ensure 	  => 'present',
    password_hash => mysql_password($glance_pwd),
  }
  mysql_user { $user_nova:
    ensure 	  => 'present',
    password_hash => mysql_password($nova_pwd),
  }
  mysql_user { $user_cinder:
    ensure 	  => 'present',
    password_hash => mysql_password($cinder_pwd),
  }
  mysql_user { $user_neutron:
    ensure 	  => 'present',
    password_hash => mysql_password($neutron_pwd),
  }
  mysql_user { $user_heat:
    ensure	  => 'present',
    password_hash => mysql_password($heat_pwd),
  }

	# USER GRANT
  # defining a new resource due to old puppet and mysql versions
  # https://tickets.puppetlabs.com/browse/PUP-1263     
  define composableMySqlGrant() {
    mysql_grant {$name:
        ensure	   => 'present',
    	user 	   => regsubst($name, '\/(.)*', ''),
        table 	   => regsubst($name, '(.)*\/', ''),
        options    => ['GRANT'],
        privileges => ['ALL'],
      }
    }
  $grant_keystone = regsubst($user_keystone, '$', '/keystone.*')
  $grant_glance   = regsubst($user_glance, '$', '/glance.*')
  $grant_nova 	  = regsubst($user_nova, '$', '/nova.*')
  $grant_nova_api = regsubst($user_nova, '$', '/nova_api.*')
  $grant_cinder   = regsubst($user_cinder, '$', '/cinder.*')
  $grant_neutron  = regsubst($user_neutron, '$', '/neutron.*')
  $grant_heat 	  = regsubst($user_heat, '$', '/heat.*')

  composableMySqlGrant{$grant_keystone: }
  composableMySqlGrant{$grant_glance: }
  composableMySqlGrant{$grant_nova: }
  composableMySqlGrant{$grant_nova_api: }
  composableMySqlGrant{$grant_cinder: }
  composableMySqlGrant{$grant_neutron: }
  composableMySqlGrant{$grant_heat: }

}
