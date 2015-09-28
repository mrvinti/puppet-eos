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
require 'puppet_x/eos/module_base'

##
# PuppetX is the toplevel namespace for working with Arista EOS nodes
module PuppetX
  ##
  # Eos is module namesapce for working with the EOS command API
  module Eos
    ##
    # The Switchport class provides a base class instance for working with
    # logical layer-2 interfaces.
    #
    class Switchport < ModuleBase

      ##
      # Retrieves the properies for a logical switchport from the
      # running-config using eAPI.
      #
      #   Example
      #   {
      #     "name": <String>,
      #     "mode": [access, trunk],
      #     "trunk_allowed_vlans": [],
      #     "trunk_native_vlan": <Integer>,
      #     "access_vlan": <Integer>
      #   }
      #
      # @param [String] name The full name of the interface to get.  The
      #   interface name must be the full interface (ie Ethernet, not Et)
      #
      # @return [Hash] a hash that includes the switchport properties
      def get(name)
        result = @api.enable("show interfaces #{name} switchport",
                             :format => 'text')
        output = result.first['output']
        attr_hash = {
          'name' => name,
          'mode' => mode_to_value(output),
          'trunk_native_vlan' => trunk_native_to_value(output),
          'access_vlan' => access_vlan_to_value(output),
        }
        cfg = get_block("interface #{name}", :config => config)
        attr_hash.merge!(parse_trunk_native_vlans(name, cfg))
        attr_hash.merge!(parse_trunk_groups(name, cfg))
        attr_hash
      end

      ##
      # Retrieves all switchport interfaces from the running-config
      #
      # @return [Array] an array of switchport hashes
      def getall
        result = @api.enable('show interfaces')
        switchports = []
        result.first['interfaces'].map do |name, attrs|
          switchports << get(name) if attrs['forwardingModel'] == 'bridged'
        end
        switchports
      end

      def parse_trunk_groups(name, cfg)
        matches = cfg.scan(/switchport trunk group ([^\s]+)/)
        values = matches.inject([]) do |arry, m|
          arry << m.first
          arry
        end
        { 'trunk_groups' => values }
      end

      def parse_trunk_native_vlans(name, cfg)
        mdata = /trunk allowed vlan (.+)$/.match(cfg)
        return { 'trunk_allowed_vlans' => [] } unless mdata[1] != 'none'
        values = mdata[1].split(',')
        { 'trunk_allowed_vlans' => values }
      end

      ##
      # Creates a new logical switchport interface in EOS
      #
      # @param [String] name The name of the logical interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def create(name)
        @api.config(["interface #{name}", 'no ip address',
                     'switchport']) == [{}, {}, {}]
      end

      ##
      # Deletes a logical switchport interface from the running-config
      #
      # @param [String] name The name of the logical interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def delete(name)
        @api.config(["interface #{name}", 'no switchport']) == [{}, {}]
      end

      ##
      # Defaults a logical switchport interface in the running-config
      #
      # @param [String] name The name of the logical interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def default(name)
        @api.config(["interface #{name}",
                     'default switchport']) == [{}, {}]
      end

      ##
      # Configures the switchport mode for the specified interafce.  Valid
      # modes are access (default) or trunk
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the mode to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_mode(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport mode'
        when false
          cmds << (value.nil? ? 'no switchport mode' : \
                                "switchport mode #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the trunk port allowed vlans for the specified interface.
      # This value is only valid if the switchport mode is configure as
      # trunk.
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The list of vlans to allow
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_trunk_allowed_vlans(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        value = value.join(',') unless value.nil?

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport trunk allowed vlan'
        when false
          cmds << (value.nil? ? 'no switchport trunk allowed vlan' : \
                                "switchport trunk allowed vlan #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the trunk port native vlan for the specified interface.
      # This value is only valid if the switchport mode is configure as
      # trunk.
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value of the trunk native vlan
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_trunk_native_vlan(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport trunk native vlan'
        when false
          cmds << (value.nil? ? 'no switchport trunk native vlan' : \
                                "switchport trunk native vlan #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the access port vlan for the specified interface.
      # This value is only valid if the switchport mode is configure
      # in access mode.
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value of the access vlan
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_access_vlan(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport access vlan'
        when false
          cmds << (value.nil? ? 'no switchport access vlan' : \
                                "switchport access vlan #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      def set_trunk_groups(name, opts = {})
        value = opts[:value] || []

        cmds = ["interface #{name}", "no switchport trunk group"]
        value.each do |v|
          cmds << "switchport trunk group #{v}"
        end

        @api.config cmds
      end

      private

      def mode_to_value(config)
        m = /Operational Mode:\s([[:alnum:]|\s]+)\n/.match(config)
        m.nil? ? 'trunk' : (m[1] == 'static access' ? 'access' : 'trunk')
      end

      def trunk_native_to_value(config)
        m = /Trunking Native Mode VLAN:\s(\d+)/.match(config)
        m.nil? ? nil : m[1]
      end

      def access_vlan_to_value(config)
        m = /Access Mode VLAN:\s(\d+)/.match(config)
        m.nil? ? nil : m[1]
      end
    end
  end
end
