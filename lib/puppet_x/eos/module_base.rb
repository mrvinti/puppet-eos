# encoding: utf-8

module PuppetX
  module Eos
    ##
    # ModuleBase provides a base class for other modules to inherit from.
    # Methods common to all modules should be placed here.
    class ModuleBase
      attr_reader :api

      ##
      # Initialize instance of Module.  The Module class provides instance
      # methods to configure module related resources on the target device.
      #
      # @param [PuppetX::Eos::Eapi] api An instance of Eapi
      #
      # @return [PuppetX::Eos::ModuleBase]
      def initialize(api)
        @api = api
      end

      ##
      # configu returns the current running configuration as a string.  This
      # method is intended to be used by subclasses.  The configuration is
      # returned as a single string object to faciliate the use of String#scan
      #
      # @api private
      #
      # @return [String]
      def config
        result = api.enable('show running-config all', :format => 'text')
        result.last['output']
      end

      ##
      # get_block returns a block of configuration from the running
      # configuration that as specified by the parent argument.  The
      # configuration block is returned as a single string  object
      #
      # @api private
      #
      # @param [String] :parent A string that represents the parent block
      #   to parse from the running config
      #
      # @return [String]
      def get_block(parent, opts = {})
        config = opts.fetch(:config, config)

        mdata = /^#{parent}$/.match(config)
        return nil unless mdata

        block_start, line_end = mdata.offset(0)

        mdata = /^!$/.match(mdata.post_match)
        return nil unless mdata

        block_len = mdata.begin(0)
        block_end = line_end - block_start + block_len

        config[block_start, block_end]
      end
    end
  end
end
