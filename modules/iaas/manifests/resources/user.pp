define iaas::resources::user (
  $password,
  $tenant,
  $email,
  $admin   = false,
  $enabled = true,
) {
  keystone_user { $name:
    ensure   => present,
    enabled  => $enabled,
    password => $password,
#    tenant   => $tenant,
    email    => $email,
  }

  if $admin == true {
    keystone_user_role { "${name}@${tenant}":
      ensure => present,
      roles  => ['heat_stack_owner', '_member_', 'admin'],
    }
  } else {
    keystone_user_role { "${name}@${tenant}":
      ensure => present,
      roles  => ['heat_stack_owner', '_member_'],
    }
  }
}
