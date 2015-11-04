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

Puppet::Type.type(:eos_prefix_list).provide(:eos) do

  # Create methods that set the @property_hash for the #flush method
  mk_resource_methods

  # Mix in the api as instance methods
  include PuppetX::Eos::EapiProviderMixin

  # Mix in the api as class methods
  extend PuppetX::Eos::EapiProviderMixin

  def self.instances
    result = eapi.Prefixlist.getall
    return [] unless result
    result.map do |attrs|
      provider_hash = { :name => namevar(attrs), :ensure => :present }
      provider_hash[:prefix_list] = attrs['prefix_list']
      provider_hash[:seqno] = attrs['seqno'].to_i
      provider_hash[:action] = attrs['action']
      provider_hash[:prefix] = attrs['prefix']
      provider_hash[:masklen] = attrs['masklen'].to_i
      provider_hash[:eq] = attrs['eq'].to_i if attrs['eq']
      provider_hash[:ge] = attrs['ge'].to_i if attrs['ge']
      provider_hash[:le] = attrs['le'].to_i if attrs['le']
      new(provider_hash)
    end
  end

  def initialize(resource = {})
    super(resource)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush = resource.to_hash
  end

  def destroy
    @property_flush = resource.to_hash
  end

  def prefix_list=(val)
    @property_flush[:prefix_list] = val
  end

  def seqno=(val)
    @property_flush[:seqno] = val
  end

  def action=(val)
    @property_flush[:action] = val
  end

  def prefix=(val)
    @property_flush[:prefix] = val
  end

  def masklen=(val)
    @property_flush[:masklen] = val
  end

  def eq=(val)
    @property_flush[:eq] = val
  end

  def ge=(val)
    @property_flush[:ge] = val
  end

  def le=(val)
    @property_flush[:le] = val
  end

  def flush
    api = eapi.Prefixlist
    desired_state = @property_hash.merge!(@property_flush)
    validate_identity(desired_state)
    case desired_state[:ensure]
    when :present
      api.update_rule(desired_state)
    when :absent
      api.remove_rule(desired_state)
    end
    @property_hash = desired_state
  end

  ##
  # validate_identity checks to make sure there are enough options specified to
  # uniquely identify a radius server resource.
  def validate_identity(opts = {})
    errors = false
    missing = [:prefix_list, :seqno].reject { |k| opts[k] }
    errors = !missing.empty?
    msg = "Invalid options #{opts.inspect} missing: #{missing.join(', ')}"
    fail Puppet::Error, msg if errors
  end
  private :validate_identity

  def self.namevar(opts)
    name = opts['prefix_list']
    seqno = opts['seqno']
    "#{name}:#{seqno}"
  end

end
