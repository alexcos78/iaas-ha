# == Class: percona::repo::apt
#
class percona::repo::apt {

  apt::key { 'apt-key':
    key	   => $params::gpg_key_fingerprint,
    ensure => present,
    notify => Exec['percona::repo::apt-get update'],
  }

  if defined('apt::sources_list') {
    # Camp2Camp/apt module
    apt::sources_list { 'percona':
      ensure  => present,
      source  => false,
      content => template ("${module_name}/repo/sources.list.erb"),
      notify  => Exec['percona::repo::apt-get update'],
      require => Apt::Key['apt-key'],
    }
  }

  if defined('apt::source') {
    # Puppetlabs/apt module
    apt::source { 'percona':
      ensure      => present,
      include_src => true,
      location    => 'http://repo.percona.com/apt',
      release     => $::lsbdistcodename,
      repos       => 'main',
      notify      => Exec['percona::repo::apt-get update'],
      require     => Apt::Key['apt-key'],
    }
  }

  exec { 'percona::repo::apt-get update':
    command     => 'apt-get update',
    path        => '/usr/bin',
    refreshonly => true,
  }


}
