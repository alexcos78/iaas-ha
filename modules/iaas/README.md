# puppet-iaas

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with iaas](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with iaas module](#beginning-with-iaas-module)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Hiera configuration](#hiera-configuration)
    * [Site configuration](#site-configuration)
    * [Node balancing](#node-balancing)
5. [References](#references)
6. [Limitations](#limitations)

## Overview

This Puppet module allows deploying a highly-available installation of OpenStack Juno on commodity servers supporting multiple networks architecture.

The present module is part of the outcomes of the Open City Platform ([OCP](http://www.opencityplatform.eu/)) National Project.

The iaas module derives from the [puppet-iaas](https://github.com/Quentin-M/puppet-iaas) module authored by Qunentin Machu.

## Module Description

By using the present module, different types of nodes can be deployed:

* Service nodes hosting databases, message queues and load balancers [installation guide](https://support.ba.infn.it/redmine/projects/automaticocp/wiki/Keepalived_HAProxy_MySQLPercona_e_RabbitMQ_in_HA_su_testbed_Puppet)
* Storage nodes hosting volumes and images using CEPH [installation guide](https://support.ba.infn.it/redmine/projects/automaticocp/wiki/CEPHPuppetIAAS)
* Controller nodes hosting API services and OpenStack core services [installation guide](https://support.ba.infn.it/redmine/projects/automaticocp/wiki/OnlyControllerPuppetIAAS)
* Network nodes hosting L2/L3 (Open vSwitch) routing and DHCP services [installation guide](https://support.ba.infn.it/redmine/projects/automaticocp/wiki/NetworkPuppetIAAS)
* Compute nodes to host guest operating systems [installation guide](https://support.ba.infn.it/redmine/projects/automaticocp/wiki/ComputePuppetIAAS)

## Setup

### Setup Requirements
This module assumes nodes running Ubuntu 14.04 (Trusty) with either Puppet Enterprise or Puppet. 

More information related to the setup requirements are available in the following guide - [Setup requirements](https://support.ba.infn.it/redmine/projects/automaticocp/wiki/TestbedPuppet)

This module depends on Hiera.

### Beginning with iaas module
To ensure high availability of the infrastructure, three Service nodes, three Storage nodes, two Controller nodes and two Network nodes must be deployed. Please make sure you have available at least ten servers. 
In addition, a number of Compute nodes must also to be available for the deployment.
The present module supports multiple external networks.

## Usage

The nodes should be deployed in the following order: 
1. Service nodes
2. Storage nodes
3. Controller nodes
4. Network nodes
5. Compute node(s)

### Hiera Configuration
Before using the module you need to collect all the information regarding your infrastructure: 
* hostnames
* networks (admin, management, data, etc.)
* Network devices
* other specific settings

The first step in using the iaas module is to configure Hiera with the specific settings of your infrastructure. 
You can find in the `examples/` directory a sample 'common.yaml' file with all of the settings required by the module.
These configuration options include Service settings, Storage settings, Network settings, OpenStack core settings and related passwords.
If any of these settings are undefined or not properly set, your deployment may fail. 

### Site configuration
The second step is to configure the manifest file with specific settings pointing to your installation. 
In this module, the `examples/` directory contains a sample 'site.pp' file that can be updated according to your deployment.
The configuration options present in this file include Service variables and node-specific configuration settings.
If any of these settings are undefined or not properly set, your deployment may fail.

### Nodes balancing
In order to balance requests across the different nodes, HAproxy and Keepalived have to be configured properly. 
Make sure also that nodes hostnames con be easily resolved to the corresponding IPs, both direct and reverse.

## References
In order to develop and test the module and its components, the following official guides and web-pages have been considered:
* [OpenStack installation guide (Ubuntu 14.04)](http://docs.openstack.org/juno/install-guide/install/apt/content/)
* [OpenStack High Availability Guide](http://docs.openstack.org/ha-guide/)
* [Puppetlabs](https://docs.puppetlabs.com/)
* [Stackforge](https://forge.puppetlabs.com/stackforge)
* [Percona](https://www.percona.com/)
* [RabbitMQ](https://www.rabbitmq.com/)
* [CEPH](http://docs.ceph.com/docs/master/)

## Limitations

This module is still under development.