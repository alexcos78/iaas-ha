class iaas::role::network (

##Public Interface method
$public_interf_method = $iaas::params::public_interf_method,

##Network1 - external
$neutron_ext1_network = '10.10.98.0/24',
$neutron_ext1_gateway = '10.10.98.1',
##Network2 - external
$neutron_ext2_network = undef,
$neutron_ext2_gateway = undef,

##DNSMASQ
$ml2_dnsmasq_servers = undef,

){

  class { 'iaas::profile::neutron::router': 
        public_interf_method    => $public_interf_method,
	dnsmasq_servers 	=> $ml2_dnsmasq_servers,
        external_network1 	=> $neutron_ext1_network, 
        external_gateway1 	=> $neutron_ext1_gateway, 
        external_network2 	=> $neutron_ext2_network,
        external_gateway2 	=> $neutron_ext2_gateway, 
        public_interface 	=> $iaas::params::public_interface,
        data_interface 		=> $iaas::params::data_interface,
        public_gateway 		=> $iaas::params::public_gateway,
        external_device1 	=> $iaas::params::external_device1,
        external_device2 	=> $iaas::params::external_device2,
        neutron_password	=> $iaas::params::os_neutron_passwd,
        neutron_secret 		=> $iaas::params::os_neutron_secret,
        region 			=> $iaas::params::os_region,
        endpoint_main 		=> $iaas::params::main_address,
        endpoint_admin 		=> $iaas::params::admin_address,
  } 
}
