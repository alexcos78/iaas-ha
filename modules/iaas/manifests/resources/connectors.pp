class iaas::resources::connectors (
#VIP1
  $endpoint_main = $iaas::params::main_address,
#VIP2
  $endpoint_admin = $iaas::params::admin_address,
#Mongo endpoints
  $mongo_admin = $iaas::params::rhmk_ips,
#Users&Passwords
  $db_keystone_password = $iaas::params::db_keystone_password,
  $db_glance_password = $iaas::params::db_glance_password,
  $db_cinder_password = $iaas::params::db_cinder_password,
  $db_nova_password  = $iaas::params::db_nova_password,
  $db_novaapi_password  = $iaas::params::db_nova_password,
  $db_neutron_password = $iaas::params::db_neutron_password,
  $db_heat_password = $iaas::params::db_heat_password,
  $db_ceilometer_password = $iaas::params::db_ceilometer_password,
 ){

  if $endpoint_admin == '' {
    $real_endpoint_admin = $endpoint_main
  }else{
    $real_endpoint_admin = $endpoint_admin
  }

  $user_keystone = 'keystone'
  $pass_keystone = $db_keystone_password
  $keystone = "mysql+pymysql://${user_keystone}:${pass_keystone}@${real_endpoint_admin}:3306/keystone"

  $user_glance = 'glance'
  $pass_glance = $db_glance_password
  $glance = "mysql+pymysql://${user_glance}:${pass_glance}@${real_endpoint_admin}:3306/glance"

  $user_cinder = 'cinder'
  $pass_cinder = $db_cinder_password
  $cinder = "mysql+pymysql://${user_cinder}:${pass_cinder}@${real_endpoint_admin}:3306/cinder"

  $user_nova = 'nova'
  $pass_nova = $db_nova_password
  $nova = "mysql+pymysql://${user_nova}:${pass_nova}@${real_endpoint_admin}:3306/nova"

  $user_novaapi = 'nova'
  $pass_novaapi = $db_novaapi_password
  $novaapi = "mysql+pymysql://${user_novaapi}:${pass_novaapi}@${real_endpoint_admin}:3306/nova_api"

  $user_neutron = 'neutron'
  $pass_neutron = $db_neutron_password
  $neutron = "mysql+pymysql://${user_neutron}:${pass_neutron}@${real_endpoint_admin}:3306/neutron"

  $user_heat = 'heat'
  $pass_heat = $db_heat_password
  $heat = "mysql+pymysql://${user_heat}:${pass_heat}@${real_endpoint_admin}:3306/heat"

#Mysql
#  $user_ceilometer = 'ceilometer'
#  $pass_ceilometer = $db_ceilometer_password
#  $ceilometer = "mysql://${user_ceilometer}:${pass_ceilometer}@${real_endpoint_admin}:3306/ceilometer"

#Mongo
  $user_ceilometer = 'ceilometer'
  $pass_ceilometer = $db_ceilometer_password
  $mongo_admin_port = suffix($mongo_admin, ':27017')
  $mongo_admin_real = join($mongo_admin_port, ',')
  $ceilometer = "mongodb://${user_ceilometer}:${pass_ceilometer}@${mongo_admin_real}/ceilometer?replicaSet=rs0"

}
