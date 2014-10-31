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
require 'puppet_x/eos/provider'

Puppet::Type.type(:eos_switchport).provide(:eos) do

  # Create methods that set the @property_hash for the #flush method
  mk_resource_methods

  # Mix in the api as instance methods
  include PuppetX::Eos::EapiProviderMixin

  # Mix in the api as class methods
  extend PuppetX::Eos::EapiProviderMixin

  def self.instances
    eapi.Switchport.getall.map do |attrs|
      provider_hash = { name: attrs['name'],
                        ensure: :present,
                        mode: attrs['mode'].to_sym,
                        trunk_allowed_vlans: attrs['trunk_allowed_vlans'],
                        trunk_native_vlan: attrs['trunk_native_vlan'],
                        access_vlan: attrs['access_vlan'] }
      new(provider_hash)
    end
  end

  def mode=(val)
    eapi.Switchport.set_mode(resource[:name], value: val)
    @property_hash[:mode] = val
  end

  def trunk_allowed_vlans=(val)
    eapi.Switchport.set_trunk_allowed_vlans(resource[:name], value: val)
    @property_hash[:trunk_allowed_vlans] = val
  end

  def trunk_native_vlan=(val)
    eapi.Switchport.set_trunk_native_vlan(resource[:name], value: val)
    @property_hash[:trunk_native_vlan] = val
  end

  def access_vlan=(val)
    eapi.Switchport.set_access_vlan(resource[:name], value: val)
    @property_hash[:access_vlan] = val
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    eapi.Switchport.create(resource[:name])
    @property_hash = { name: resource[:name], ensure: :present }
    self.mode = resource[:mode] if resource[:mode]
    self.trunk_allowed_vlans = resource[:trunk_allowed_vlans] \
                               if resource[:trunk_allowed_vlans]

    self.trunk_native_vlan = resource[:trunk_native_vlan] \
                             if resource[:trunk_native_vlan]

    self.access_vlan = resource[:access_vlan] if resource[:access_vlan]
  end

  def destroy
    eapi.Switchport.delete(resource[:name])
    @property_hash = { name: resource[:name], ensure: :absent }
  end
end
