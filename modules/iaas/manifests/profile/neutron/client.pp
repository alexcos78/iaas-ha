class iaas::profile::neutron::client (

  $data_interface = undef,

) {

#Mitaka, start br-* interfaces
  class { 'iaas::resources::rclocal_file':
    br_interfaces => 'ifconfig br-int up && ifconfig br-tun up',
  }

  include iaas::profile::neutron::common

#  if $::brtun_eval != ' ' {

    class { '::neutron::agents::ml2::ovs':
      enable_tunneling => true,
      local_ip         => $::facts["ipaddress_${data_interface}"],
      enabled          => true,
      tunnel_types     => ['gre'],
    } 

#Mitaka, start br-* interfaces

#    exec { "start_brall":
#      command => "ifconfig br-int up && ifconfig br-tun up",
#      path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",
#    }

#  }    

}
