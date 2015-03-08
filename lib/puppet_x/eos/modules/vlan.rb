require 'puppet_x/eos/module_base'

##
# Eos is the toplevel namespace for working with Arista EOS nodes
module PuppetX
  ##
  # Eapi is module namesapce for working with the EOS command API
  module Eos
    ##
    # The Vlan class provides an interface for working wit VLAN resources
    # in EOS.  All configuration is sent and received using eAPI.  In order
    # to use this class, eAPI must be enablined in EOS.  This class
    # can be instatiated either using the Eos::Eapi::Switch.load_class
    # method or used directly.
    #
    class Vlan < ModuleBase

      ##
      # Returns the vlan data for the provided id with the
      # show vlan <id> command.  If the id doesn't exist then
      # nil is returned
      #
      # Example:
      #   [
      #     { "sourceDetail": <string>, "vlans": {...} },
      #     { "trunkGroups": {...} }
      #   ]
      #
      # @return [nil, Hash<String, String|Hash|Array>] Hash describing the
      #   vlan configuration specified by id.  If the id is not
      #   found then nil is returned
      def getall
        @api.enable(['show vlan', 'show vlan trunk group'])
      end

      ##
      # Adds a new VLAN resource in EOS setting the VLAN ID to id.  The
      # VLAN ID must be in the valid range of 1 through 4094
      #
      # @param [String] id The VLAN identifier (e.g. 1)
      #
      # @return [Boolean] returns true if the command completed successfully
      def create(id)
        @api.config("vlan #{id}") == [{}]
      end

      ##
      # Deletes an existing VLAN resource in EOS as specified by ID.  If
      # the supplied VLAN ID does not exist no error is raised
      #
      # @param [String] id The VLAN identifier (e.g. 1)
      #
      # @return [Boolean] always returns true
      def delete(id)
        @api.config("no vlan #{id}") == [{}]
      end

      ##
      # Defaults an existing VLAN resource in EOS as specified by ID.  If
      # the supplied VLAN ID does not exist no error is raised.  Note: setting
      # a vlan to default is equivalent to negating it
      #
      # @param [String] id The VLAN identifier (e.g. 1)
      #
      # @return [Boolean] returns true if the command completed successfully
      def default(id)
        @api.config("default vlan #{id}") == [{}]
      end

      ##
      # Configures the VLAN name of the VLAN specified by ID.  set_name maps
      # to the EOS name WORD command.  Spaces in the name will be converted
      # to _
      #
      # @param [Hash] opts The configuration parameters for the VLAN
      # @option opts [String] :id The VLAN ID to change
      # @option opts [string] :value The value to set the name to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_name(id, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["vlan #{id}"]
        case default
        when true
          cmds << 'default name'
        when false
          cmds << (value.nil? ?  'no name' : "name #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the administrative state of the VLAN specified by ID.  The
      # set_state function accepts 'active' or 'suspend' to configure the
      # VLAN state.
      #
      # @param [Hash] opts The configuration parameters for the VLAN
      # @option opts [String] :id The VLAN ID to change
      # @option opts [string] :value The value to set the state to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_state(id, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["vlan #{id}"]
        case default
        when true
          cmds << 'default state'
        when false
          cmds << (value.nil? ? 'no state' : "state #{value}")
        end
        @api.config(cmds) == [{}, {}]
      end

      ##
      # Configures the trunk group value for the VLAN specified by ID.  The
      # trunk group setting is typically used to associate VLANs with MLAG
      # configurations
      #
      # @param [Hash] opts The configuration parameters for the VLAN
      # @option opts [String] :id The VLAN ID to change
      # @option opts [string] :value The value to set the trunk group to
      # @option opts [Boolean] :default The value should be set to default
      def set_trunk_group(id, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["vlan #{id}"]
        case default
        when true
          cmds << 'default trunk group'
        when false
          cmds << 'no trunk group'
          value.each { |tg| cmds << "trunk group #{tg}" }
        end
        @api.config(cmds)
      end
    end
  end
end
