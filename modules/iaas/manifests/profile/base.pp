class iaas::profile::base (
  $dns_servers,
  $dns_searchdomain,
#  $ssh_public_key,
) {

## Keep-alive values
  sysctl::value { "net.ipv4.tcp_keepalive_time": value => "300" }
  sysctl::value { "net.ipv4.tcp_keepalive_probes": value => "9" }
  sysctl::value { "net.ipv4.tcp_keepalive_intvl": value => "75" }

## Ubuntu repository for OpenStack Juno
  if ($::operatingsystem == 'Ubuntu') {
    include apt::update

    apt::source { 'ubuntu-cloud-archive':
      location => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
#      release => "${::lsbdistcodename}-updates/juno",
      release => "${::lsbdistcodename}-updates/mitaka",
      repos => 'main',
      required_packages => 'ubuntu-cloud-keyring',
    }

    Exec['apt_update'] -> Package<||>

  } else {
    fail("\'$::operatingsystem\' not supported")
  }

## Locales
  class { 'locales':
    default_locale  => 'en_US.UTF-8',
    locales         => ['en_US.UTF-8 UTF-8'],
    lc_ctype => 'en_US.UTF-8'
  }

## VLAN module - uncomment if needed
#  package { 'vlan': }
#  kmod::load {'8021q':
#    require => Package['vlan']
#  }

#  # Network
  class { 'resolv_conf':
    nameservers => $dns_servers,
    domainname  => $dns_searchdomain,
  }

## SSH - uncomment if needed
#  class { 'ssh::server':
#    storeconfigs_enabled => false,
#    options => {
#      'PermitRootLogin'        => 'yes',
#      'Port'                   => [22],
#    }
#  }
#  file { "/root/.ssh":
#    ensure => "directory",
#    owner  => "root",
#    group  => "root",
#    mode   => 755,
#  }
#  file { '/root/.ssh/authorized_keys2':
#    owner => root,
#    group => root,
#    mode => 644,
#    content => $ssh_public_key
#  }
}
