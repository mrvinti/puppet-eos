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
    # The Ospf class provides a base class instance for working with
    # instances of OSPF
    #
    class Ospf < ModuleBase

      DEFAULT_ROUTER_ID = ''

      ##
      # Returns the base interface hash representing physical and logical
      # interfaces in EOS using eAPI
      #
      # Example
      #   {
      #       "1": { "router_id": <string> },
      #       "2": {...}
      #   }
      #
      # @return [Hash] returns an Hash
      def getall
        response = {}
        response.merge!(instances)
        response.merge!(interfaces)
        response
      end

      ##
      # Creates a new instance of OSPF routing
      #
      # @param [String] inst The instance id to create
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def create(inst)
        @api.config("router ospf #{inst}") == [{}]
      end

      ##
      # Deletes an instance of OSPF routing
      #
      # @param [String] inst The instance id to delete
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def delete(inst)
        @api.config("no router ospf #{inst}") == [{}]
      end

      ##
      # Defaults an instance of OSPF routing
      #
      # @param [String] inst The instance id to delete
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def default(inst)
        @api.config("default router ospf #{inst}") == [{}]
      end

      ##
      # Configures the OSPF process router-id
      #
      # @param [String] inst The instance of ospf to configure
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the router-id to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_router_id(inst, opts = {})
        value = opts[:value] || false
        default = opts[:default] || false

        cmds = ["router ospf #{inst}"]
        case default
        when true
          cmds << 'default router-id'
        when false
          cmds << (value ? "router-id #{value}" : 'no router-id')
        end
        @api.config(cmds) == [{}, {}]
      end

      def set_passive_interfaces(inst, opts = {})
        values = opts[:value]
        current = instances['instances'][inst]['passive_interfaces']

        cmds = ["router ospf #{inst}"]

        current.each do |name|
          cmds << "no passive-interface #{name}" unless values.include?(name)
        end

        values.each do |name|
          cmds << "passive-interface #{name}"
        end

        @api.config(cmds)
      end

      def set_active_interfaces(inst, opts = {})
        values = opts[:value]
        current = instances['instances'][inst]['active_interfaces']

        cmds = ["router ospf #{inst}"]

        current.each do |name|
          cmds << "passive-interface #{name}" unless values.include?(name)
        end

        values.each do |name|
          cmds << "no passive-interface #{name}"
        end

        @api.config(cmds)
      end

      def set_passive_interface_default(inst, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["router ospf #{inst}"]
        case default
        when true
          cmds << 'default passive-interface default'
        when false
          cmds << (value ? "passive-interface default" :
                           "no passive-interface default")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # max_lsa configures the max-lsa value for the specified OSPF process
      #
      # @param [String] inst The instance of ospf to configure
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the max-lsa to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_max_lsa(inst, opts = {})
        value = opts[:value] || false
        default = opts[:default] || false

        cmds = ["router ospf #{inst}"]
        case default
        when true
          cmds << 'default max-lsa'
        when false
          cmds << (value ? "max-lsa #{value}" : 'no max-lsa')
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # maximum_paths configures the maximim-paths value for the
      # specified OSPF process
      #
      # @param [String] inst The instance of ospf to configure
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the maximum-paths to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_maximum_paths(inst, opts = {})
        value = opts[:value] || false
        default = opts[:default] || false

        cmds = ["router ospf #{inst}"]
        case default
        when true
          cmds << 'default maximum-paths'
        when false
          cmds << (value ? "maximum-paths #{value}" : 'no maximum-paths')
        end
        @api.config(cmds) == [{}, {}]
      end

      def update_redistribution(proto, instance_id, opts = {})
        route_map = opts[:route_map]
        cmds = ["router ospf #{instance_id}"]
        cfg = "redistribute #{proto}"
        cfg << " route-map #{route_map}" if route_map
        cmds << cfg
        @api.config(cmds)
      end

      def remove_redistribution(proto, instance_id)
        cmds = ["router ospf #{instance_id}"]
        cmds << "no redistribute #{proto}"
        require 'pry'; binding.pry
        @api.config(cmds)
      end


      def update_network(network, instance_id, area)
        cmds = ["router ospf #{instance_id}"]
        cmds << "network #{network} area #{area}"
        @api.config(cmds)
      end

      def remove_network(network, instance_id, area)
        cmds = ["router ospf #{instance_id}"]
        cmds << "no network #{network} area #{area}"
        @api.config(cmds)
      end

      ##
      # Parses the running-configuration to retreive all OSPF instances
      #
      # @return [Hash]
      def instances
        running_config = config('^router ospf')
        instances = running_config.scan(/^router ospf (\d)/)
        values = instances.inject({}) do |hsh, inst|
          inum = inst.first
          config = get_block("router ospf #{inum}", :config => running_config)
          hsh[inum] = {}
          hsh[inum].merge!(parse_router_id(config))
          hsh[inum].merge!(parse_maximum_paths(config))
          hsh[inum].merge!(parse_max_lsa(config))
          hsh[inum].merge!(parse_areas(config))
          hsh[inum].merge!(parse_redistribution(config))
          hsh[inum].merge!(parse_ospf_interfaces(config))
          hsh[inum].merge!(parse_passive_interface_default(config))
          hsh
        end
        { 'instances' => values }
      end

      ##
      # parse_router_id scans the provided configuration block an extracts the
      # ospf router-id value if configured.  If the router-id is not configured
      # then the value of DEFAULT_ROUTER_ID is returned.  The returned Hash is
      # intended to be merged into the instances resource Hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource Hash attribute
      def parse_router_id(config)
        mdata = /router-id ([^\s]+)/.match(config)
        return { 'router_id' => mdata ? mdata[1] : DEFAULT_ROUTER_ID }
      end
      private :parse_router_id

      ##
      # parse_maximum_paths scans the provided configuration block and extracts
      # the ospf maximum paths value.  The maximum paths value is expected to
      # always be present in the configuration block.  The returned Hash is
      # intended to be merged into the instances resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Ojbect>] resource Hash attribute.
      def parse_maximum_paths(config)
        mdata = /maximum-paths (\d+)/.match(config)
        return { 'maximum_paths' => mdata[1].to_i }
      end
      private :parse_maximum_paths

      ##
      # parse_max_lsa scans the provided configuration block and extracts the
      # ospf max lsa value.  The max lsa value is expected to always be present
      # in the configuration block.  The returned Hash is intended to be merged
      # into the instances resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Ojbect>] resource Hash attribute.
      def parse_max_lsa(config)
        mdata = /max-lsa (\d+)/.match(config)
        return { 'max_lsa' => mdata[1].to_i }
      end
      private :parse_max_lsa

      ##
      # parse_areas scans the providec configuration block and extracts the
      # ospf network and area statemetns.  The networks are collected into the
      # areas and the entire hash returned.  The returned hash is intended to
      # be merged into the instances resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Ojbect>] resource Hash attribute.
      def parse_areas(config)
        networks = config.scan(/network ([^\s]+) area ([^\s]+)/)
        values = networks.inject({}) do |hsh, cfg|
          net, area = cfg
          hsh[area] = {'networks' => []} unless hsh.include?(area)
          hsh[area]['networks'] << net
          hsh
        end
        { 'areas' => values }
      end
      private :parse_areas

      ##
      # parse_redistribution scans the provided configuration block and
      # extracts the ospf redistribute config statements. The returned hash
      # is intended to be merged into the instances resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Ojbect>] resource Hash attribute.
      def parse_redistribution(config)
        regex = /redistribute (static|connected)(?: route-map ([^\s]+))?/
        matches = config.scan(regex)
        values = matches.inject({}) do |hsh, m|
          proto, routemap = m
          hsh[proto] = { 'route_map' => routemap }
          hsh
        end
        { 'redistribution' => values }
      end
      private :parse_redistribution


      ##
      # parse_ospf_interfaces scans the nodes configuration and extracts active
      # and passive interfaces
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource Hash attribute.
      def parse_ospf_interfaces(config)
        default = config.include?('passive-interface default')
        interfaces = configured_interfaces
        interfaces.flatten! unless !interfaces || interfaces.empty?

        case default
        when true
          active = config.scan(/no passive-interface ([^\s]+)/)
          active.flatten! unless !active || active.empty?
          passive = interfaces.reject { |name| active.include?(name) }
        when false
          passive = config.scan(/\s{4}passive-interface ([^\s]+)/)
          passive.flatten! unless !passive || passive.empty?
          active = interfaces.reject { |name| passive.include?(name) }
        end
        { 'passive_interfaces' => passive, 'active_interfaces' => active,
          'passive_interface_default' => default }

      end
      private :parse_ospf_interfaces

      ##
      # configured_interfaces scans the nodes state to return the list of
      # interfaces that ospf is enabled on.
      #
      # @api private
      #
      # @return [Array<String>] list of interface names
      def configured_interfaces
        result = @api.enable('show ip ospf interface brief', :format => 'text')
        result.first['output'].scan(/\s{4}([EVPL][a-z]+[^\s]+)/)
      end
      private :configured_interfaces

      ##
      # parse_passive_interface_default scans the provided configuration block
      # and extracts the passive-interface defualt value.
      #
      # @api proviate
      #
      # @return [Hash<Symbol, Object>] resource Hash attribute
      def parse_passive_interface_default(config)
        cmd = 'passive-interface default'
        return { 'passive_interface_default' => config.include?(cmd) }
      end
      private :parse_passive_interface_default

      ##
      # Parses the running-configuration to retreive all OSPF interfaces
      #
      # @return [Hash] a hash of key/value pairs
      def interfaces
        running_config = config('^interface')
        interfaces = running_config.scan(/^interface (.+)/)
        values = interfaces.inject({}) do |hsh, name|
          next if name =~ /^Ma/
          config = get_block("interface #{name.first}", :config => running_config)
          hsh[name.first] = {}
          hsh[name.first].merge!(parse_network_type(config))
          hsh
        end
        return { 'interfaces' => values }
      end

      def parse_network_type(config)
        m = /ip ospf network point-to-point/ =~ config
        { 'network_type' => m.nil? ? 'broadcast' : 'point_to_point' }
      end

      ##
      # Configures the OSPF interface network type
      #
      # @param [String] inst The instance of ospf to configure
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the network_type
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_network_type(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        value.gsub!('_', '-') if value
        value = nil if value == 'broadcast'

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default ip opsf network'
        when false
          cmds << (value ? "ip ospf network #{value}" :
                           'no ip ospf network')
        end
        @api.config(cmds) == [{}, {}]
      end
    end
  end
end
