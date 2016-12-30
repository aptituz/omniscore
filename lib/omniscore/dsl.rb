require 'omniscore/matchers'

class Omniscore
  class DSL
    include Omniscore::Matchers

    attr_accessor :activity_rules
    attr_accessor :total_score
    attr_accessor :score

    def initialize
      @activity_rules = {}
      @total_score    = 0
      @score          = 0
    end

    def scoreboard
      Omniscore::Runner.scoreboard
    end

    def add_score(amount, options = {})
      match = (options.has_key?(:if)) ? options[:if].match? : true
      if match
        scoreboard.day_score    += amount
        scoreboard.total_score  += amount
      end
    end

    def on_added_task(&block)
      activity_rule(:added_task, block)
    end

    def on_added_project(&block)
      activity_rule(:added_project, block)
    end

    def on_completed_task(&block)
      activity_rule(:completed_task, block)
    end

    def on_completed_project(&block)
      activity_rule(:completed_project, block)
    end

    def on_reviewed_project(&block)
      activity_rule(:reviewed_project, block)
    end

    def activity_rule(activity, block)
      activity_rules[activity] ||= []
      activity_rules[activity] << block
    end


    def self.eval_rules
      rules = File.read('newrules.rb')
      object = Omniscore::DSL.new
      object.instance_eval(rules)
      object
    end
  end
end