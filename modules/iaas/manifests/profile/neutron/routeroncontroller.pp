#Multiple external networks supported
class iaas::profile::neutron::routeroncontroller (
  $public_interface = undef,
  $data_interface = undef,
  $public_gateway = undef,
  $public_interf_method = undef,

  $external_device1 = undef,
  $external_network1 = undef,
  $external_gateway1 = undef,

  $external_device2 = undef,
  $external_network2 = undef,
  $external_gateway2 = undef,

  $neutron_password = 'neutron',
  $neutron_secret = undef,

  $region = undef,

#VIP1
  $endpoint_main = undef,
#VIP2
  $endpoint_admin = undef,

#Mitaka NEW
  $dnsmasq_servers = undef,

) {

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  sysctl::value { "net.ipv4.ip_forward": value => "1" }
  sysctl::value { "net.ipv4.conf.all.rp_filter": value => "0" }
  sysctl::value { "net.ipv4.conf.default.rp_filter": value => "0" }

  sysctl::value { "net.ipv4.conf.all.accept_redirects": value => "0" }
  sysctl::value { "net.ipv4.conf.default.accept_redirects": value => "0" }
  sysctl::value { "net.ipv4.conf.all.send_redirects": value => "0" }
  sysctl::value { "net.ipv4.conf.default.send_redirects": value => "0" }

  package { 'ifupdown-extra': }

  class { '::neutron::agents::dhcp':
    enable_isolated_metadata => true,
    enable_metadata_network => true,
    dnsmasq_config_file => " ",
#    dnsmasq_dns_servers => '131.154.3.1,131.154.1.3',
    dnsmasq_dns_servers => join(any2array($dnsmasq_servers), ','),
    
  }

  class { '::neutron::agents::vpnaas':
#double_external_network
#    external_network_bridge => "br-ex",
    external_network_bridge => ' ',
  }
  class { '::neutron::agents::lbaas': }
  class { '::neutron::agents::metering': }

  class { '::neutron::agents::metadata':
    shared_secret => $neutron_secret,
    metadata_ip => $real_endpoint_admin,
    metadata_port => '8775',
    enabled => true,
  }

#Assign localIP
  $datanetip = "ipaddress_${data_interface}"
  $datanetipvalue = inline_template("<%= scope.lookupvar(datanetip) %>")
#  notify {"IP address: $datanetipvalue" :
#    loglevel => alert,
#  }
  if $datanetipvalue {
    $local_ip = $::facts["ipaddress_${data_interface}"]
  } else {
    $local_ip = $::ipaddress_br_ex1
  }

  if $external_device2 {
    $bridge_mappings= ['physnet1:br-ex1','physnet2:br-ex2']
  } else {
    $bridge_mappings=['physnet1:br-ex1']
  }

  class { '::neutron::agents::ml2::ovs':
      enable_tunneling => true,
      local_ip => $local_ip,
      enabled => true,
      tunnel_types => ['gre'],
#double_external_network, variable modified
#      bridge_mappings => ['external:br-ex'],
      bridge_mappings => $bridge_mappings,
  }

# Set public network if $public_interface != $external_device1
  if $public_gateway {
    file { "/etc/network/interfaces.d/${public_interface}.cfg":
      ensure => 'absent',
    } ->
    network_config { $public_interface:
      ensure  => 'present',
      family  => 'inet',
      method  => $public_interf_method,
    } ->
    network_route { 'route_default':
      ensure => 'present',
      gateway => $public_gateway,
      interface => $public_interface,
      netmask => '0.0.0.0',
      network => 'default',
      require => Package['ifupdown-extra']
    }
  }

# Set loopback interface
  network_config { 'lo':
    ensure => 'present',
    family => 'inet',
    method => 'loopback',
    onboot => 'true',
  }

# Evaluate br-ex1, if present set it
  if $::brex1_eval != 'br-ex1' {

# Store initial configuration from the public interface (assigned by DHCP) to restore on br-ex
    $public_ipaddress1 = $::facts["ipaddress_${external_device1}"]
    $public_netmask1 = $::facts["netmask_${external_device1}"]
    $public_macaddr1 = $::facts["macaddress_${external_device1}"]

    if $public_ipaddress1 {
     file { "/etc/network/interfaces.d/${external_device1}.cfg":
       ensure => 'absent',
     } ->      
      network_config { $external_device1:
        ensure  => 'present',
        family  => 'inet',
        method  => 'manual',
        options => {
          'up' => "ifconfig ${external_device1} 0.0.0.0 promisc up",
          'down' => "ifconfig ${external_device1} promisc down",
        },
      } ->
      network_config { 'br-ex1':
        ensure  => 'present',
        family  => 'inet',
        method  => 'static',
        ipaddress => $public_ipaddress1,
        netmask => $public_netmask1,
      } -> 
      vs_port { $external_device1:
        ensure => present,
        bridge => 'br-ex1',
        require => Class['::neutron::agents::ml2::ovs'],
      } ->
      network_route { 'route_ext1':
        ensure => 'present',
        gateway => $external_gateway1,
        interface => 'br-ex1',
        netmask => '0.0.0.0',
        network => 'default',
        require => Package['ifupdown-extra']
      } ->
      exec { "set_br-ex1_hwaddr":
        command => "ovs-vsctl set bridge br-ex1 other-config:hwaddr=$public_macaddr1",
        path    => "/usr/local/bin/:/bin/:/usr/bin:/sbin/:/usr/sbin/",
      } ->
      exec { "restart_external1":
        command => "ifconfig $external_device1 0.0.0.0 promisc",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",
      } ->
      exec { "restart_br-ex1":
        command => "ifdown br-ex1 && ifup br-ex1",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",     
      } ->
#Mitaka, start br-* interfaces
      exec { "start_brn":
        command => "ifconfig br-int up && ifconfig br-tun up",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",
      }
    } else { 
      file { "/etc/network/interfaces.d/${external_device1}.cfg":
        ensure => 'absent',
      } ->
      network_config { $external_device1:
        ensure  => 'present',
        family  => 'inet',
        method  => 'manual',
        options => {
          'up' => "ifconfig ${external_device1} 0.0.0.0 promisc up",
          'down' => "ifconfig ${external_device1} promisc down",
        },
      } ->
      vs_port { $external_device1:
        ensure => present,
        bridge => 'br-ex1',
        require => Class['::neutron::agents::ml2::ovs'],
      } ->
      exec { "set_br-ex1_hwaddr":
        command => "ovs-vsctl set bridge br-ex1 other-config:hwaddr=$public_macaddr1",
        path    => "/usr/local/bin/:/bin/:/usr/bin:/sbin/:/usr/sbin/",
      } ->
      exec { "restart_external1":
        command => "ifconfig $external_device1 0.0.0.0 promisc",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",
      } ->
#Mitaka, start br-* interfaces
      exec { "start_brall":
        command => "ifconfig br-int up && ifconfig br-tun up && ifconfig br-ex1 up",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",
      } 
    }
  }

# Configure second bridge
  if $external_device2 {
  
# Evaluate br-ex2, if presetn set it
    if $::brex2_eval != 'br-ex2' {

# Store initial configuration from the public interface (assigned by DHCP) to restore on br-ex
      $public_ipaddress2 = $::facts["ipaddress_${external_device2}"]
      $public_netmask2 = $::facts["netmask_${external_device2}"]
      $public_macaddr2 = $::facts["macaddress_${external_device2}"]

      file { "/etc/network/interfaces.d/${external_device2}.cfg":
        ensure => 'absent',
      } ->
      network_config { $external_device2:
        ensure  => 'present',
        family  => 'inet',
        method  => 'manual',
        options => {
          'up' => "ifconfig ${external_device2} 0.0.0.0 promisc up",
          'down' => "ifconfig ${external_device2} promisc down",
        },
      } ->
      vs_port { $external_device2:
        ensure => present,
        bridge => 'br-ex2',
        require => Class['::neutron::agents::ml2::ovs'],
      } ->
      exec { "set_br-ex2_hwaddr":
        command => "ovs-vsctl set bridge br-ex2 other-config:hwaddr=$public_macaddr2",
        path    => "/usr/local/bin/:/bin/:/usr/bin:/sbin/:/usr/sbin/",
      } ->
      exec { "restart_external2":
        command => "ifconfig $external_device2 0.0.0.0 promisc",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/sbin/",
      } ->
#Mitaka, start br-ex2 interfaces on reboot
      class { 'iaas::resources::rclocal_file':
        br_interfaces => 'ifconfig br-int up && ifconfig br-tun up && ifconfig br-ex1 up && ifconfig br-ex2 up',
      }
    }
  } else {
#Mitaka, start br-* interfaces on reboot
    class { 'iaas::resources::rclocal_file':
      br_interfaces => 'ifconfig br-int up && ifconfig br-tun up && ifconfig br-ex1 up',
    }
  }
}
