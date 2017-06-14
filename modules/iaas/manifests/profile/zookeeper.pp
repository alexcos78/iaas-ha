class iaas::profile::zookeeper (
  $admin_interface 	     = undef, 
  $servers 	 	     = undef,
  $zookeeper_id    	     = undef,
  $zookeeper_max_connections = 128,
) {
# Python-zake package 
  package { 'python-zake': }

  class { '::zookeeper':
    id => $zookeeper_id,
    client_ip => getvar("::ipaddress_${admin_interface}"), #$::facts["ipaddress_${admin_interface}"],
    servers => $servers,
    max_allowed_connections => $zookeeper_max_connections,
  }

}
