#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for neutron::agents::vpnaas class
#

require 'spec_helper'

describe 'neutron::agents::vpnaas' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure              => 'present',
      :enabled                     => true,
      :vpn_device_driver           => 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver',
      :interface_driver            => 'neutron.agent.linux.interface.OVSInterfaceDriver',
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron vpnaas agent' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it_configures 'openswan vpnaas_driver'

    it 'configures vpnaas_agent.ini' do
      is_expected.to contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(p[:vpn_device_driver]);
      is_expected.to contain_neutron_vpnaas_agent_config('ipsec/ipsec_status_check_interval').with_value('<SERVICE DEFAULT>');
      is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/external_network_bridge').with_value('<SERVICE DEFAULT>');
    end

    context 'with external_network_bridge as br-ex' do
      before do
      params.merge!(
        :external_network_bridge => 'br-ex'
      )
      end

      it 'configures vpnaas_agent.ini' do
        is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/external_network_bridge').with_value(p[:external_network_bridge]);
      end
    end

    it 'installs neutron vpnaas agent package' do
      if platform_params.has_key?(:vpnaas_agent_package)
        is_expected.to contain_package('neutron-vpnaas-agent').with(
          :name   => platform_params[:vpnaas_agent_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        is_expected.to contain_package('neutron').with_before(/Package\[neutron-vpnaas-agent\]/)
      end
    end

    it 'configures neutron vpnaas agent service' do
      is_expected.to contain_service('neutron-vpnaas-service').with(
        :name    => platform_params[:vpnaas_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :require => 'Class[Neutron]',
        :tag     => 'neutron-service',
      )
      is_expected.to contain_service('neutron-vpnaas-service').that_subscribes_to('Package[neutron]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('neutron-vpnaas-service').without_ensure
      end
    end
  end

  shared_examples_for 'openswan vpnaas_driver' do
    it 'installs openswan packages' do
      if platform_params.has_key?(:vpnaas_agent_package)
        is_expected.to contain_package('openswan').with_before(['Package[neutron-vpnaas-agent]'])
      end
      is_expected.to contain_package('openswan').with(
        :ensure => 'present',
        :name   => platform_params[:openswan_package]
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian'
      }))
    end

    let :platform_params do
      { :openswan_package     => 'openswan',
        :vpnaas_agent_package => 'neutron-vpn-agent',
        :vpnaas_agent_service => 'neutron-vpn-agent' }
    end

    it_configures 'neutron vpnaas agent'
    it 'configures subscription to neutron-vpnaas-agent package' do
      is_expected.to contain_service('neutron-vpnaas-service').that_subscribes_to('Package[neutron-vpnaas-agent]')
    end

    context 'when configuring the LibreSwan driver' do
      before do
      params.merge!(
        :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver'
      )
      end

      it 'fails when configuring LibreSwan on Debian' do
        is_expected.to raise_error(Puppet::Error, /LibreSwan is not supported on osfamily Debian/) 
      end
    end
  end

  context 'on RedHat 6 platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge(
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '6.5',
          :operatingsystemmajrelease => 6 }))
    end

    let :platform_params do
      { :openswan_package     => 'openswan',
        :vpnaas_agent_package => 'openstack-neutron-vpnaas',
        :vpnaas_agent_service => 'neutron-vpn-agent'}
    end

    it_configures 'neutron vpnaas agent'
  end

  context 'on RedHat 7 platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge(
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '7.1.2',
          :operatingsystemmajrelease => 7 }))
    end

    let :platform_params do
      { :openswan_package     => 'libreswan',
        :libreswan_package    => 'libreswan',
        :vpnaas_agent_package => 'openstack-neutron-vpnaas',
        :vpnaas_agent_service => 'neutron-vpn-agent'}
    end

    it_configures 'neutron vpnaas agent'

    context 'when configuring the LibreSwan driver' do
      before do
      params.merge!(
        :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver'
      )
      end

      it 'configures LibreSwan' do
        is_expected.to contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(params[:vpn_device_driver]);
        is_expected.to contain_package('libreswan').with(
          :ensure => 'present',
          :name   => platform_params[:libreswan_package]
        )
        end
      end
  end
end
