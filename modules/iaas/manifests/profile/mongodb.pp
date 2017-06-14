class iaas::profile::mongodb (
   $admin_interface = undef,
   $hosts           = undef,
   $bootstrap       = false,
   $master          = false,
   $key             = undef,
   $password        = undef,
   $mongouser       = 'ceilometer',
   $mongopasswd     = 'ceilometer',
){

  class {'::mongodb::globals':
#    manage_package_repo => true,
#    bind_ip => [$::facts["ipaddress_eth1"]], #[$::facts["ipaddress_${admin_interface}"]],
  }

  if $master { 
     if $bootstrap {
        class {'::mongodb::server':
          bind_ip 	 => ['127.0.0.1', getvar("::ipaddress_${admin_interface}") ],
          port 		 => '27017',
          auth 	 	 => true,
          journal 	 => 'true',
          keyfile	 => '/etc/mongodb.key',
          key 		 => $key,   
          verbose 	 => true,
          create_admin   => true,
          store_creds    => true,
          admin_username => "admin",
          admin_password => $password,
        } ->
            
        class {'::mongodb::client': } ->
           
        mongodb::db { 'ceilometer':
          user     => $mongouser,
          password => $mongopasswd,
          roles    => ['dbAdmin','readWrite'],
        }
     } else {
        class {'::mongodb::server':
           bind_ip 	  => ['127.0.0.1',getvar("::ipaddress_${admin_interface}") ],
           replset 	  => 'rs0',
           replset_config => { 'rs0' => { ensure  => present, members => suffix($hosts, ':27017')}  },
           port 	  => '27017',
           auth 	  => true,
           journal 	  => 'true',
           keyfile 	  => '/etc/mongodb.key',
           key 		  => $key,
           verbose 	  => true,
           store_creds    => true,
           admin_username => "admin",
           admin_password => $password,
         }
     }
 
  } else {

     class {'::mongodb::server':
       bind_ip 		=> ['127.0.0.1',getvar("::ipaddress_${admin_interface}")],
       port		=> '27017',
       auth 		=> true,
       journal 		=> 'true',
       keyfile 		=> '/etc/mongodb.key',
       key 		=> $key,
       verbose 		=> true,
       store_creds    	=> true,
       admin_username 	=> "admin",
       admin_password 	=> $password,
       replset        	=> 'rs0',
     } ->

     class {'::mongodb::client': }

  }
}
