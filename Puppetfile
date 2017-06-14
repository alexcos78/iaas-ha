#!/usr/bin/env ruby
#^syntax detection

forge "https://forge.puppetlabs.com"

# use dependencies defined in metadata.json
metadata

# use dependencies defined in Modulefile
# modulefile

# A module from git
# mod 'puppetlabs-ntp',
#   :git => 'git://github.com/puppetlabs/puppetlabs-ntp.git'
#mod 'puppet',
#    :git => "git://github.com/puppetlabs/puppetlabs-puppet"
mod 'ceph',
    :git => "https://baltig.infn.it/ocp-tools/ceph.git",
    :ref => '2.0.0'

# A module from a git branch/tag
# mod 'puppetlabs-apt',
#   :git => 'https://github.com/puppetlabs/puppetlabs-apt.git',
#   :ref => '1.4.x'
#mod 'staging',
#    :git => "https://github.com/nanliu/puppet-staging.git"
#    :ref => '1.0.4'
#mod 'puppetdb',
#    :git => "git://github.com/puppetlabs/puppetlabs-puppetdb",
#    :ref => '5.0.0'

# Modulo percona AutomaticOCP
mod 'ocp-tools/percona',
    :git => "https://baltig.infn.it/ocp-tools/percona.git",
    :ref => '1.3.1'

# Modulo mongo AutomaticOCP 
mod 'ocp-tools/mongodb',
    :git => "https://baltig.infn.it/ocp-tools/mongodb.git",
    :ref => '1.0.0'
    
# Modulo Zabbix AutomaticOCP 
mod 'ocp-tools/zabbix',
    :git => "https://baltig.infn.it/ocp-tools/zabbix.git",
    :ref => '2.1.0'