class iaas::role::iaasbase (){
# Classes
  class { 'iaas::profile::base': 
        dns_servers             => $iaas::params::dns_servers,
        dns_searchdomain        => $iaas::params::dns_searchdomain,
  } 
}
