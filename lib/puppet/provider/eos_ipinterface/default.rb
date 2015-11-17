#
# Copyright (c) 2014, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   Neither the name of Arista Networks nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'puppet/type'

begin
  require 'puppet_x/eos/provider'
rescue LoadError => detail
  # Work around #7788 (Rubygems support for modules)
  require 'pathname' # JJM WORK_AROUND #14073
  module_base = Pathname.new(__FILE__).dirname
  require module_base + "../../../" + "puppet_x/eos/provider"
end

Puppet::Type.type(:eos_ipinterface).provide(:eos) do

  # Create methods that set the @property_hash for the #flush method
  mk_resource_methods

  # Mix in the api as instance methods
  include PuppetX::Eos::EapiProviderMixin

  # Mix in the api as class methods
  extend PuppetX::Eos::EapiProviderMixin

  def self.instances
    result = eapi.Ipinterface.getall
    result.map do |name, attrs|
      provider_hash = { :name => name, :ensure => :present }
      provider_hash[:address] = attrs['address']
      provider_hash[:mtu] = attrs['mtu'].to_s
      provider_hash[:helper_addresses] = attrs['helper_addresses']
      new(provider_hash)
    end
  end

  def address=(val)
    eapi.Ipinterface.set_address(resource['name'], :value => val)
    @property_hash[:address] = val
  end

  def helper_addresses=(val)
    eapi.Ipinterface.set_helper_addresses(resource['name'], :value => val)
    @property_hash[:helper_addresses] = val
  end

  def mtu=(val)
    eapi.Ipinterface.set_mtu(resource['name'], :value => val)
    @property_hash[:mtu] = val
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    eapi.Ipinterface.create(resource[:name])
    @property_hash = { :name => resource[:name], :ensure => :present }
    self.address = resource[:address] if resource[:address]
    self.mtu = resource[:mtu] if resource[:mtu]
    self.helper_addresses = resource[:helper_addresses] if resource[:helper_addresses]
  end

  def destroy
    eapi.Ipinterface.delete(resource[:name])
    @property_hash = { :name => resource[:name], :ensure => :absent }
  end
end
