class iaas::profile::fastcgi (
  $enable_fastcgi = false,
) {

  if $enable_fastcgi {
    ceph::rgw::apache_fastcgi { 'radosgw.gateway':
      admin_email      => 'root@localhost',
      docroot          => '/var/www',
      fcgi_file        => '/var/www/s3gw.fcgi',
      rgw_dns_name     => $::fqdn,
      rgw_port         => 80,
      rgw_socket_path  => $::ceph::params::rgw_socket_path,
      syslog           => true,
      ceph_apache_repo => true,
    } 
  }

}
