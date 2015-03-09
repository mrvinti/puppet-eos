require 'puppet_x/eos/module_base'

module PuppetX

  module Eos

    class Staticroute < ModuleBase

      # Regular expression to extract static route  attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrappping and indentation with the /x flag.
      ROUTE_REGEXP = /ip[ ]route
                      (?:[ ]([^\s]+)\/(\d+))
                      (?:[ ]([^\s]+))
                      (?:[ ](\d+))
                      (?:[ ]tag[ ](\d+))
                      (?:[ ]name[ ](.+))?/x

      def getall
        instances = config.scan(ROUTE_REGEXP)
        return nil unless instances
        instances.map do |route|
          parse_route(route)
        end
      end

      def parse_route(config)
        hsh = {}
        hsh['prefix'] = config[0]
        hsh['masklen'] = config[1]
        hsh['nexthop'] = config[2]
        hsh['distance'] = config[3]
        hsh['tag'] = config[4]
        hsh['route_name'] = config[5]
        hsh
      end

      def update_route(opts = {})
        remove_route(opts)
        command = "ip route #{opts[:prefix]}/#{opts[:masklen]}"
        command << " #{opts[:nexthop]}"
        command << " name #{opts[:route_name]}" if opts[:route_name]
        @api.config command
      end

      def remove_route(opts = {})
        command = "no ip route #{opts[:prefix]}/#{opts[:masklen]}"
        command << " #{opts[:nexthop]}"
        command << " name #{opts[:route_name]}" if opts[:route_name]
        @api.config command
      end
    end
  end
end
