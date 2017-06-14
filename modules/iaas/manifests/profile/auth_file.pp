class iaas::profile::auth_file (

$admin_password = 'admin',
$admin_tenant = 'admin',

$region = $iaas::params::os_region,

#VIP1
  $endpoint_main = $iaas::params::main_address,
#VIP2
  $endpoint_admin = $iaas::params::admin_address,

) {


  if $endpoint_admin == '' {
    $endpoint_hostname = $endpoint_main
  }else{
    $endpoint_hostname = $endpoint_admin
  }


  class { 'iaas::resources::auth_file':
    admin_tenant    => $admin_tenant,
    admin_password  => $admin_password,
    region_name     => $region,
    controller_node => $endpoint_hostname,
  }
}
