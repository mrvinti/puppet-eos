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
# Eos is the toplevel namespace for working with Arista EOS nodes
module PuppetX
  ##
  # Eapi is module namesapce for working with the EOS command API
  module Eos
    ##
    # The Vxlan provides an instance for managing vxlan virtual tunnel
    # interfaces in EOS
    #
    class Vxlan < ModuleBase

      ##
      # Returns the Vxlan logical interface from the running-config
      #
      # Example
      #   {
      #     "Vxlan1": {
      #       "source_interface": <string>,
      #       "multicast_group": <string>,
      #       "udp_port": <integer>
      #       "vlans": {...}
      #     }
      #   }
      #
      # @return [Hash] returns key/value pairs that present the logical
      #   interface configuration
      def getall
        result = @api.enable('show running-config all interfaces Vxlan1',
                             :format => 'text')
        config = result.first['output']
        return {} if config.empty?
        response = {}
        response['source_interface'] = parse_source_interface(config)
        response['multicast_group'] = parse_multicast_group(config)
        response['udp_port'] = parse_udp_port(config)
        response.merge!(parse_vlans(config))
        { 'Vxlan1' => response }
      end
      ##
      # parse_source_interface scans the interface config block and returns the
      # value of the vxlan source-interace.  If the source-interface is not
      # configured then the value of DEFAULT_SRC_INTF is used.  The hash
      # returned is intended to be merged into the interface resource hash
      #
      # @param [String] :config The interface configuration block to extract
      #   the vxlan source-interface value from
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_source_interface(config)
        mdata = /source-interface ([^\s]+)$/.match(config)
        mdata.nil? ? '' : mdata[1]
      end

      ##
      # parse_multicast_group scans the interface config block and returns the
      # value of the vxlan multicast-group.  If the multicast-group is not
      # configured then the value of DEFAULT_MCAST_GRP is used.  The hash
      # returned is intended to be merged into the interface resource hash
      #
      # @param [String] :config The interface configuration block to extract
      #   the vxlan multicast-group value from
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_multicast_group(config)
        mdata = /multicast-group ([^\s]+)$/.match(config)
        mdata.nil? ? '' : mdata[1]
      end

      ##
      # parse_udp_port scans the interface config block and returns the value
      # of the vxlan udp-port setting.  The vxlan udp-port value is expected to
      # always be present in the configuration.  The returned value is intended
      # to be merged into the interface resource Hash
      #
      # @api private
      #
      # @param [String] :config The interface configuration block to parse the
      #   vxlan udp-port value from
      #
      # @return [Hash<Symbol, Object>] resource Hash attribute
      def parse_udp_port(config)
        mdata = /^\s{3}vxlan udp-port (\d+)/.match(config)
        mdata.nil? ? '' : mdata[1].to_i
      end

      def parse_vlans(config)
        matches = config.scan(/vxlan vlan (\d+) vni (\d+)/)
        values = matches.inject({}) do |hsh, m|
          vlan, vni = m
          hsh[vlan] = { 'vni' => vni }
          hsh
        end
        { 'vlans' => values }
      end

      ##
      # Creates a new logical vxlan virtual interface in the running-config
      #
      # @return [Boolean] returns true if the command completed successfully
      def create
        @api.config('interface Vxlan1') == [{}]
      end

      ##
      # Deletes an existing vxlan logical interface from the running-config
      #
      # @return [Boolean] always returns true
      def delete
        @api.config('no interface Vxlan1') == [{}]
      end

      ##
      # Defaults an existing vxlan logical interface from the running-config)
      #
      # @return [Boolean] returns true if the command completed successfully
      def default
        @api.config('default interface Vxlan1') == [{}]
      end

      ##
      # Configures the source-interface parameter for the Vxlan interface
      #
      # @param [Hash] opts The configuration parameters for the VLAN
      # @option opts [string] :value The value to set the name to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_source_interface(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['interface Vxlan1']
        case default
        when true
          cmds << 'default vxlan source-interface'
        when false
          cmds << (value.nil? ?  'no vxlan source-interface' : \
                                 "vxlan source-interface #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the multicast-group parameter for the Vxlan interface
      #
      # @param [Hash] opts The configuration parameters for the VLAN
      # @option opts [string] :value The value to set the name to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_multicast_group(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['interface Vxlan1']
        case default
        when true
          cmds << 'default vxlan multicast-group'
        when false
          cmds << (value.nil? ?  'no vxlan multicast-group' : \
                                 "vxlan multicast-group #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the vxlan udp-port value for the Vxlan interface
      #
      # @param [Hash] opts The configuration parameters for the VLAN
      # @option opts [string] :value The value to set the udp-port to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_udp_port(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['interface Vxlan1']
        case default
        when true
          cmds << 'default vxlan udp-port'
        when false
          cmds << (value.nil? ?  'no vxlan udp-port' : \
                                 "vxlan udp-port #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      def update_vlan(vlan, vni)
        cmds = ["interface Vxlan1", "vxlan vlan #{vlan} vni #{vni}"]
        @api.config cmds
      end

      def remove_vlan(vlan)
        cmds = ["interface Vxlan1", "no vxlan vlan #{vlan} vni"]
        @api.config cmds
      end
    end
  end
end
