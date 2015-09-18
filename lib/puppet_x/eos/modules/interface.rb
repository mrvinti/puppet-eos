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
    # The Interface class provides a base class instance for working with
    # physical and logical interfaces.
    #
    class Interface < ModuleBase


      def get(name)
        cfg = get_block("interface #{name}", :config => config)
        resource = { 'name' => name }
        resource.merge!(parse_description(cfg))
        resource.merge!(parse_shutdown(cfg))
        resource.merge!(parse_speed(cfg)) if name.include?('Et')
        resource.merge!(parse_lacp_priority(cfg)) if name.include?('Et')
        resource
      end

      ##
      # Returns the base interface hash representing physical and logical
      # interfaces in EOS using eAPI
      #
      # @return [Hash] returns a hash of interfaces indexed by interface name
      #   with key/value pairs representing the running config
      def getall
        interfaces = config.scan(/^interface (.+)/)
        interfaces.flatten! unless !interfaces || interfaces.empty?
        interfaces.inject({}) do |hsh, name|
          data = get(name)
          hsh[name] = data if data
          hsh
        end
      end

      def parse_description(config)
        mdata = /description (.+)/.match(config)
        { 'description' => mdata.nil? ? '' : mdata[1] }
      end

      def parse_shutdown(config)
        value = config.include?('no shutdown')
        { 'shutdown' => !value }
      end

      def parse_speed(config)
        mdata = /speed (.+)/.match(config)
        { 'speed' => mdata.nil? ? 'default' : "#{mdata[1]}" }
      end

      def parse_lacp_priority(config)
        mdata = /lacp port-priority (\d+)/.match(config)
        { 'lacp_priority' => mdata[1] }
      end

      ##
      # Configures the interface object back to system wide defaults using
      # the EOS command api
      #
      # @param [String] name The name of the interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def default(name)
        @api.config("default interface #{name}") == [{}]
      end

      ##
      # Creates a new logical interface on the node.
      #
      # @param [String] name The name of the logical interface.  It must be
      #   a full valid EOS interface name (ie Ethernet, not Et)
      #
      # @return [Boolean] True if the command succeeds or False if the command
      #   fails or is not supported (for instance trying to create a physical
      #   interface that already exists)
      def create(name)
        return false if name.match(/^[Et|Ma]/)
        @api.config("interface #{name}") == [{}]
      end

      ##
      # Deletes an existing logical interface.
      #
      # @param [String] name The name of the interface.  It must be a full
      #   valid EOS interface name (ie Vlan, not Vl)
      #
      # @return [Boolean] True if the command succeeds or False if the command
      #   fails or is not supported (for instance trying to delete a physical
      #   interface)
      def delete(name)
        return false if name.match(/^[Et|Ma]/)
        @api.config("no interface #{name}") == [{}]
      end

      ##
      # Configures the interface shutdown state
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the state to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_shutdown(name, opts = {})
        value = opts[:value] || false
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default shutdown'
        when false
          cmds << (value ? 'shutdown' : 'no shutdown')
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the interface description
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the description to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_description(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default description'
        when false
          cmds << ((value.nil? || value.length == 0) ? 'no description' : \
                                                       "description #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      def set_lacp_priority(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default lacp port-priority'
        when false
          cmds << (value.nil? ? 'no lacp port-priority' :
                                "lacp port-priority #{value}")
        end
        @api.config(cmds)
      end


      ##
      # Configures the interface speed value
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the speed to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_speed(name, opts = {})
        value = ((opts[:value] == :default) ? nil : opts[:value])
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default speed'
        when false
          cmds << ((value.nil?) ? 'no speed' : "speed #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end
    end
  end
end
