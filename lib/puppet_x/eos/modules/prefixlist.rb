require 'puppet_x/eos/module_base'

module PuppetX

  module Eos

    class Prefixlist < ModuleBase

      # Regular expression to extract a prefix list attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrappping and indentation with the /x flag.
      RULE_REGEXP = /ip[ ]prefix[-]list[ ](:?[^\s]+)[ ]
                     (?:seq[ ](\d+))
                     (?:[ ](permit|deny))
                     (?:[ ]([^\s]+))
                     (?:[ ]eq[ ](\d+))?
                     (?:[ ]ge[ ](\d+))?
                     (?:[ ]le[ ](\d+))?/x

      def getall
        instances = config.scan(RULE_REGEXP)
        return nil unless instances
        instances.map do |rule|
          parse_rule(rule)
        end
      end

      def parse_rule(config)
        hsh = {}
        hsh['prefix_list'] = config[0]
        hsh['seqno'] = config[1]
        hsh['action'] = config[2]
        hsh['prefix'] = config[3].split('/')[0]
        hsh['masklen'] = config[3].split('/')[1]
        hsh['eq'] = config[4]
        hsh['ge'] = config[5]
        hsh['le'] = config[6]
        hsh
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
        @api.config "no ip prefix-list #{name} seq #{seqno}"
      end
    end
  end
end
