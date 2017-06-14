class iaas::profile::haproxy (
  $stats_enabled = undef,
  $stats_ports = undef,
  $stats_refresh = undef,
  $stats_login = undef,
  $stats_password = undef,
  $stats_uri = undef,
  $main_address = undef,
  $admin_address = undef,
  $percona_hosts = undef,
  $percona_ips = undef,
  $controller_hosts = undef,
  $controller_ips = undef,
) {
  if $admin_address == undef {
    $internal_address = $main_address
  } else {
    $internal_address = $admin_address
  }
  class { '::haproxy':
    defaults_options => {
      'mode' => 'http',
#     'log' => 'global',
      'option' => [
#	'tcplog',
	'dontlognull',
	'redispatch',
      ],
      'retries' => '3',
      'timeout' => [
        'http-request 10s',
        'queue 1m',
        'connect 10s',
        'client 1m',
        'server 1m',
	'http-keep-alive 10s',
        'check 10s',
      ],
      'maxconn' => '4096',
    },
  }

  if $stats_enabled {
    haproxy::listen { 'stats':
      ipaddress => $main_address,
      mode => 'http',
      ports => $stats_ports,
      options => {
        'stats' => [
          'enable',
          'hide-version',
          "refresh ${stats_refresh}",
          'show-node',
          "auth ${stats_login}:${stats_password}",
          "uri ${stats_uri}"
        ],
      }
    }
  }

  haproxy::listen { 'percona_cluster':
    ipaddress => $internal_address,
    mode => 'tcp',
    ports => '3306',
    options => {
      'option' => ['tcplog','httpchk','tcpka'],
      'balance' => 'leastconn',
      'timeout' => [
         'client 90m',
         'server 90m',
       ],
    }
  }

  $main_host = $percona_hosts[0]
  $main_ip = $percona_ips[0]
  #$backup_hosts = $percona_hosts
  $backup_hosts = delete_at( $percona_hosts, 0)
  #$backup_ips = $percona_ips
  $backup_ips = delete_at($percona_ips, 0)
  haproxy::balancermember { 'percona_cluster_prior':
    listening_service => 'percona_cluster',
    ports             => '3307',
    server_names      => $main_host,
    ipaddresses       => $main_ip,
    options           => 'check port 9200',
  }
  haproxy::balancermember { 'percona_cluster_secondaries':
    listening_service => 'percona_cluster',
    ports             => '3307',
    server_names      => $backup_hosts, 
    ipaddresses       => $backup_ips, 
    options           => 'check port 9200 backup',
  }

  haproxy::listen { 'keystone_admin_cluster':
    bind    => {"${internal_address}:35357"  => [],},
    options => {
      'option' => ['tcplog','httpchk','tcpka'],
      'balance' => 'source',
    }
  }

  haproxy::balancermember { 'keystone_admin_cluster':
     listening_service => 'keystone_admin_cluster',
     ports             => '35357',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }


  if $admin_address == undef {
       haproxy::listen { 'keystone_api_cluster':
         bind    => {
                 "${main_address}:5000"  => [],
               },
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
  	haproxy::listen { 'keystone_api_cluster':
    		bind    => {
    		        "${main_address}:5000"  => [],
    		        "${internal_address}:5000" => [],
    		      },
    		options => {
    		  'option' => ['tcplog','httpchk','tcpka'],
    		  'balance' => 'source',
    		}
       }
  }

  haproxy::balancermember { 'keystone_api_cluster':
     listening_service => 'keystone_api_cluster',
     ports             => '5000',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'glance_api_cluster':
         ipaddress => $main_address,
         ports => '9292',
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
       haproxy::listen { 'glance_api_cluster':
         bind    => {
           "${main_address}:9292"  => [],
           "${internal_address}:9292" => [],
         },
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  }

  haproxy::balancermember { 'glance_api_cluster':
     listening_service => 'glance_api_cluster',
     ports             => '9292',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }


 haproxy::listen { 'glance_registry_cluster':
    ipaddress => $internal_address,
    ports => '9191',
    options => {
      'option' => ['tcplog','tcpka'],
      'balance' => 'source',
    }
  }

  haproxy::balancermember { 'glance_registry_cluster':
     listening_service => 'glance_registry_cluster',
     ports             => '9191',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
        haproxy::listen { 'cinder_api_cluster':
          ipaddress => $main_address,
          ports => '8776',
          options => {
            'option' => ['tcplog','httpchk','tcpka'],
            'balance' => 'source',
          }
        }
  } else {
        haproxy::listen { 'cinder_api_cluster':
          bind    => {
            "${main_address}:8776"  => [],
            "${internal_address}:8776" => [],
          },
          options => {
            'option' => ['tcplog','httpchk','tcpka'],
            'balance' => 'source',
          }
        }
  }

  haproxy::balancermember { 'cinder_api_cluster':
     listening_service => 'cinder_api_cluster',
     ports             => '8776',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'nova_compute_api_cluster':
          ipaddress => $main_address,
          ports => '8774',
          options => {
            'option' => ['tcplog','httpchk','tcpka'],
            'balance' => 'source',
          }
        }
    } else {
        haproxy::listen { 'nova_compute_api_cluster':
          bind    => {
            "${main_address}:8774"  => [],
            "${internal_address}:8774" => [],
          },
          options => {
            'option' => ['tcplog','httpchk','tcpka'],
            'balance' => 'source',
          }
        }
  }

  haproxy::balancermember { 'nova_compute_api_cluster':
     listening_service => 'nova_compute_api_cluster',
     ports             => '8774',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

 haproxy::listen { 'nova_metadata_api_cluster':
    ipaddress => $internal_address,
    ports => '8775',
    options => {
      'option' => ['tcplog','tcpka'],
      'balance' => 'source',
    }
  }

  haproxy::balancermember { 'nova_metadata_api_cluster':
     listening_service => 'nova_metadata_api_cluster',
     ports             => '8775',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
        haproxy::listen { 'nova_novncproxy_cluster':
           ipaddress => $main_address,
           ports => '6080',
           options => {
             'option' => ['tcplog','tcpka'],
             'balance' => 'source',
           }
         }
    } else {
        haproxy::listen { 'nova_novncproxy_cluster':
          bind    => {
            "${main_address}:6080"  => [],
            "${internal_address}:6080" => [],
          },
          options => {
            'option' => ['tcplog','tcpka'],
            'balance' => 'source',
          }
        }
  }

  haproxy::balancermember { 'nova_novncproxy_cluster':
     listening_service => 'nova_novncproxy_cluster',
     ports             => '6080',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

#Mitaka deprecated support to EC2
#    if $admin_address == undef {
#        haproxy::listen { 'nova_ec2_api_cluster':
#          ipaddress => $main_address,
#          ports => '8773',
#          options => {
#            'option' => ['tcplog','tcpka'],
#            'balance' => 'source',
#          }
#        }
#      } else {
#        haproxy::listen { 'nova_ec2_api_cluster':
#          bind    => {
#            "${main_address}:8773"  => [],
#            "${internal_address}:8773" => [],
#          },
#          options => {
#            'option' => ['tcplog','tcpka'],
#            'balance' => 'source',
#          }
#        }
#  }
#
#  haproxy::balancermember { 'nova_ec2_api_cluster':
#     listening_service => 'nova_ec2_api_cluster',
#     ports             => '8773',
#     server_names      => $controller_hosts,
#     ipaddresses       => $controller_ips,
#     options           => 'check inter 2000 rise 2 fall 5',
#  }


  if $admin_address == undef {
       haproxy::listen { 'neutron_api_cluster':
         ipaddress => $main_address,
         ports => '9696',
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
 	 haproxy::listen { 'neutron_api_cluster':
 	   bind    => {
 	           "${main_address}:9696"  => [],
 	           "${internal_address}:9696" => [],
 	         },
 	   options => {
 	     'option' => ['tcplog','httpchk','tcpka'],
 	     'balance' => 'source',
 	   }
 	 }
  }

  haproxy::balancermember { 'neutron_api_cluster':
     listening_service => 'neutron_api_cluster',
     ports             => '9696',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'heat_api_cluster':
         ipaddress => $main_address,
         ports => '8004',
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
 	 haproxy::listen { 'heat_api_cluster':
 	   bind    => {
 	           "${main_address}:8004"  => [],
 	           "${internal_address}:8004" => [],
 	         },
 	   options => {
 	     'option' => ['tcplog','httpchk','tcpka'],
 	     'balance' => 'source',
 	   }
 	 }
  }

  haproxy::balancermember { 'heat_api_cluster':
     listening_service => 'heat_api_cluster',
     ports             => '8004',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'heat_api_cfn_cluster':
         ipaddress => $main_address,
         ports => '8000',
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
  	haproxy::listen { 'heat_api_cfn_cluster':
  	   bind    => {
  	          "${main_address}:8000"  => [],
  	          "${internal_address}:8000" => [],
  	        },
  	  options => {
  	    'option' => ['tcplog','httpchk','tcpka'],
  	    'balance' => 'source',
  	  }
  	}
  }

  haproxy::balancermember { 'heat_api_cfn_cluster':
     listening_service => 'heat_api_cfn_cluster',
     ports             => '8000',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'heat_api_watch_cluster':
         ipaddress => $main_address,
         ports => '8003',
         options => {
           'option' => ['tcplog','httpchk','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
 	 haproxy::listen { 'heat_api_watch_cluster':
 	   bind    => {
 	           "${main_address}:8003"  => [],
 	           "${internal_address}:8003" => [],
 	         },
 	   options => {
 	     'option' => ['tcplog','httpchk','tcpka'],
 	     'balance' => 'source',
 	   }
 	 }
  }

  haproxy::balancermember { 'heat_api_watch_cluster':
     listening_service => 'heat_api_watch_cluster',
     ports             => '8003',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'ceilometer_api_cluster':
         ipaddress => $main_address,
         ports => '8777',
         options => {
           'option' => ['tcplog','tcpka'],
           'balance' => 'source',
         }
       }
  } else {
 	 haproxy::listen { 'ceilometer_api_cluster':
 	   bind    => {
 	           "${main_address}:8777"  => [],
 	           "${internal_address}:8777" => [],
 	         },
 	   options => {
 	     'option' => ['tcplog','tcpka'],
 	     'balance' => 'source',
 	   }
 	 }
  }

  haproxy::balancermember { 'ceilometer_api_cluster':
     listening_service => 'ceilometer_api_cluster',
     ports             => '8777',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }

  if $admin_address == undef {
       haproxy::listen { 'horizon_api_cluster':
         ipaddress => $main_address,
         ports => '80',
	 mode	=> 'http',
         options => {
           'option' => ['httpchk','tcpka','forwardfor'],
           'balance' => 'source',
         }
       }
  } else {
 	 haproxy::listen { 'horizon_api_cluster':
 	   bind    => {
 	           "${main_address}:80"  => [],
 	           "${internal_address}:80" => [],
 	         },
 	   mode => 'http',
 	   options => {
 	     'option' => ['httpchk','tcpka','forwardfor'],
 	     'balance' => 'source',
 	   }
 	 }
  }

  haproxy::balancermember { 'horizon_cluster':
     listening_service => 'horizon_cluster',
     ports             => '80',
     server_names      => $controller_hosts,
     ipaddresses       => $controller_ips,
     options           => 'check inter 2000 rise 2 fall 5',
  }
}
