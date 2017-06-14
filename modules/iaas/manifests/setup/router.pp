# A convenience method to set up a router between
# a private subnet and the public network. The
# $title of the resource is 'routername:subnet',
# where routername is the name of the router to assign
# to the tenant "test" and subnet is the name of the
# subnet to connect the router to.

define iaas::setup::router {
  $valarray = split($title, ':')
  $tenant = 'test'
  $rname  = $valarray[0]
  $subnet = $valarray[1]

  if $rname == 'test1' {

    neutron_router { $rname:
      tenant_name          => $tenant,
      gateway_network_name => 'public1',
      require              => [Neutron_network['public1'], Neutron_subnet[$subnet]]
    } ->

    neutron_router_interface  { $title:
      ensure => present
    }
  }

  if $rname == 'test2' {

    neutron_router { $rname:
      tenant_name          => $tenant,
      gateway_network_name => 'public2',
      require              => [Neutron_network['public2'], Neutron_subnet[$subnet]]
    } ->
    neutron_router_interface  { $title:
      ensure => present
    }
  }

}