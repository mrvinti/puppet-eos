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

Puppet::Type.type(:eos_route_map).provide(:eos) do

  # Create methods that set the @property_hash for the #flush method
  mk_resource_methods

  # Mix in the api as instance methods
  include PuppetX::Eos::EapiProviderMixin

  # Mix in the api as class methods
  extend PuppetX::Eos::EapiProviderMixin

  def self.instances
    result = eapi.Routemap.getall
    return [] unless result
    instances = []
    result.each do |(name, rules)|
      rules.inject({}) do |hsh, (seqno, attrs)|
        hsh = { :name => namevar(name, seqno), :ensure => :present }
        hsh[:route_map] = name
        hsh[:seqno] = seqno.to_i
        hsh[:action] = attrs['action'].to_sym
        hsh[:match] = attrs['match']
        hsh[:set] = attrs['set']
        instances << new(hsh)
      end
    end
    instances
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    validate_identity(resource)
    eapi.Routemap.create(resource[:route_map], resource[:action],
                         resource[:seqno])

    @property_hash = { :name => "#{resource[:route_map]}:#resource[:seqno]}",
                       :ensure => :present,
                       :route_map => resource[:route_map],
                       :seqno => resource[:seqno] }

    self.action = resource[:action] if resource[:action]
    self.match = resource[:match] if resource[:match]
    self.set = resource[:set] if resource[:set]
  end

  def destroy
    eapi.Routemap.delete(resource[:route_map], resource[:action], resource[:seqno])
    @property_hash = { :name => "#{resource[:route_map]}:#resource[:seqno]}",
                       :ensure => :absent }
  end

  def action=(val)
    eapi.Routemap.update_action(resource[:route_map], resource[:seqno],
                                val.to_s)

    @property_hash[:action] = val
  end

  def match=(val)
    eapi.Routemap.update_match_rules(resource[:route_map], resource[:seqno],
                                     resource[:action].to_s, val)
    @property_hash[:match] = val
  end

  def set=(val)
    eapi.Routemap.update_set_rules(resource[:route_map], resource[:seqno],
                                   resource[:action].to_s, val)
    @property_hash[:set] = val
  end

  ##
  # validate_identity checks to make sure there are enough options specified to
  # uniquely identify a route-map resource.
  def validate_identity(opts = {})
    errors = false
    missing = [:route_map, :action, :seqno].reject { |k| opts[k] }
    errors = !missing.empty?
    msg = "Invalid options #{opts.inspect} missing: #{missing.join(', ')}"
    fail Puppet::Error, msg if errors
  end
  private :validate_identity

  def self.namevar(name, seqno)
    "#{name}:#{seqno}"
  end

end
