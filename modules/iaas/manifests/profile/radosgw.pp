class iaas::profile::radosgw (
  $enable_rgw = false,
  $os_endpoint = $iaas::params::main_hostname,
  $os_admin_token = $iaas::params::os_admin_token,
  $secret_user = undef,
) {

  if $enable_rgw {
    ceph::rgw { 'radosgw.gateway':
      pkg_radosgw        => $::ceph::params::pkg_radosgw,
      rgw_data           => "/var/lib/ceph/radosgw/ceph-radosgw.gateway",
      user               => 'root',
      keyring_path       => "/etc/ceph/ceph.client.radosgw.gateway.keyring",
      log_file           => '/var/log/ceph/radosgw.log',
      rgw_dns_name       => $::fqdn,
      rgw_socket_path    => '/var/run/ceph/ceph.radosgw.gateway.fastcgi.sock',
      syslog             => true,
      rgw_port           => '80',
      frontend_type      => 'civetweb',
      rgw_frontends      => "civetweb port=7481",
      rgw_print_continue => 'false',
    } 
#    exec { "ocp_user_create":
#      command => "radosgw-admin user create --uid=ocpuser --display-name=ocpuser",
#      path    => "/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/",
#    } ->
#    exec { "ocp_user_buckets":
#      command => "radosgw-admin user modify --uid=ocpuser --max-buckets=0",
#      path    => "/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/",
#    } ->
#    exec { "ocp_subuser_create":
#      command => "radosgw-admin subuser create --uid=ocpuser --subuser=ocpuser:swift --access=full",
#      path    => "/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/",
#    } ->
#    exec { "ocp_key_create":
#      command => "radosgw-admin key create --subuser=ocpuser:swift --key-type=swift --secret=$secret_user",
#      path    => "/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/",
#    }

    ceph::rgw::keystone { 'radosgw.gateway':
      rgw_keystone_admin_token         => $os_admin_token,
      rgw_keystone_url                 => "http://${os_endpoint}:5000",
      rgw_keystone_version             => 'v2.0',
      rgw_keystone_accepted_roles      => '_member_, Member, admin',
      rgw_keystone_token_cache_size    => 500,
      rgw_keystone_revocation_interval => 600,
      nss_db_path                      => '/var/lib/ceph/nss',
      user                             => 'root',
    }

  }
}



