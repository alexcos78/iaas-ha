# == Class: iaas::resources::rclocal_file
#
# Modify the rc.local file 
#
# === Parameters
#
# [*admin_password*]
#   (required) Admin password.
#
class iaas::resources::rclocal_file(
  $br_interfaces = 'ifconfig br-int up && ifconfig br-tun up && ifconfig br-ex1 up && ifconfig br-ex2 up',
) {

  file { '/etc/rc.local':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/rc.local.erb")
  }
}
