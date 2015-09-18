require 'puppet_x/eos/module_base'

module PuppetX

  module Eos

    class Routemap < ModuleBase

      def get(name)
        clauses = config.scan(/route-map #{name} .+/)
        return nil unless clauses

        clauses.inject({}) do |hsh, clause|
          cfg = get_block(clause, :config => config)
          action, seqno = parse_action_seqno(cfg)
          hsh[seqno] = { 'action' => action }
          hsh[seqno].merge!(parse_clause(cfg))
          hsh
        end
      end

      def getall
        instances = config.scan(/route-map ([^\s]+)/)
        return nil if !instances || instances.empty?
        instances.flatten!.uniq!
        instances.inject({}) do |hsh, name|
          data = get(name)
          hsh[name] = data unless data.nil?
          hsh
        end
      end

      def parse_clause(config)
        resp = {}
        resp['match'] = config.scan(/match (.+)/).flatten
        resp['set'] = config.scan(/set (.+)/).flatten
        resp
      end

      def parse_action_seqno(config)
        config.scan(/route-map [^\s]+ (\w+) (\d+)/).first
      end

      def create(name, action, seqno)
        cmd = "route-map #{name} #{action} #{seqno}"
        @api.config cmd
      end

      def delete(name, action, seqno)
        cmd = "no route-map #{name} #{action} #{seqno}"
        @api.config cmd
      end

      def update_action(name, seqno, action)
        cmd = "route-map #{name} #{action} #{seqno}"
        @api.config cmd
      end

      def update_match_rules(name, seqno, action, rules)
        remove_match_rules(name, action, seqno)
        cmds = ["route-map #{name} #{action} #{seqno}"]
        rules.each do |rule|
          cmds << "match #{rule}"
        end
        @api.config(cmds)
      end

      def update_set_rules(name, seqno, action, rules)
        remove_set_rules(name, action, seqno)
        cmds = ["route-map #{name} #{action} #{seqno}"]
        rules.each do |rule|
          cmds << "set #{rule}"
        end
        @api.config(cmds)
      end

      def remove_match_rules(name, action, seqno)
        cfg = get(name)
        return nil unless cfg.has_key?(seqno)
        cfg[name][seqno]['match'].each do |rule|
          @api.config("no #{rule}")
        end
      end

      def remove_set_rules(name, action, seqno)
        cfg = get(name)
        return nil unless cfg.has_key?(seqno)
        cfg[name][seqno]['set'].each do |rule|
          @api.config("no #{rule}")
        end
      end
    end
  end
end
