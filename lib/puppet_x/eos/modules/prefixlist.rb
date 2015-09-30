require 'puppet_x/eos/module_base'

module PuppetX

  module Eos

    class Prefixlist < ModuleBase

      # Regular expression to extract a prefix list attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrappping and indentation with the /x flag.
      RULE_REGEXP = /(?:seq[ ](\d+))
                     (?:[ ](permit|deny))
                     (?:[ ]([^\s]+))
                     (?:[ ]eq[ ](\d+))?
                     (?:[ ]ge[ ](\d+))?
                     (?:[ ]le[ ](\d+))?/x

      def get(name)
        results = config.scan(/^ip prefix-list #{name}/)
        return nil unless result
        instances = results.scan(/^ip prefix-list #{name} (.*)$/)
        return nil unless instances
        instances.inject({}) do |hsh, inst|
          hsh[name] = [] unless hsh.include?(name)
          hsh[name] << parse_rule(inst.first)
          hsh
        end

      end

      def getall
        results = config.scan(/^ip prefix-list/)
        return nil unless result
        instances = results.scan(/ip prefix-list ([^\s]+)/)
        return nil unless instances
        instances.inject({}) do |hsh, name|
          hsh.merge!(get(name.first))
          hsh
        end
      end

      def parse_rule(config)
        tuples = config.scan(RULE_REGEXP)
        tuples.inject({}) do |hsh, (seqno, action, net, eq, ge, le)|
          hsh['seqno'] = seqno
          hsh['action'] = action
          hsh['prefix'] = net.split('/')[0]
          hsh['masklen'] = net.split('/')[1]
          hsh['eq'] = eq
          hsh['ge'] = ge
          hsh['le'] = le
          hsh
        end
      end

      def update_rule(opts = {})
        remove_rule(opts)
        command = "ip prefix-list #{opts[:prefix_list]} seq #{opts[:seqno]}"
        command << " #{opts[:action]} #{opts[:prefix]}/#{opts[:masklen]}"
        command << " eq #{opts[:eq]}" if opts[:eq]
        command << " ge #{opts[:ge]}" if opts[:ge]
        command << " le #{opts[:le]}" if opts[:le]
        @api.config command
      end

      def remove_rule(opts = {})
        name = opts[:prefix_list]
        seqno = opts[:seqno]
        @api.config "no ip prefix-list #{name} seqno #{seqno}"
      end
    end
  end
end
