class Omniscore
  module Runner
    def self.current_subject
      @@current_subject
    end

    def self.set_current_subject(subject)
      @@current_subject = subject
    end

    def self.scoreboard
      Omniscore::Scoreboard.instance
    end

    def self.process(activities, scoring_rules)
      activities.sort_by { |date,activities| date }.each do |date,day_activities|
        scoreboard.day_score    = 0

        day_activities.each do |activity|
          if scoring_rules.activity_rules.has_key?(activity.type)
            activity_rules = scoring_rules.activity_rules[activity.type]
            activity_rules.each do |block|
              current_subject =  activities.subject_for(activity)
              Omniscore::Runner.set_current_subject(current_subject)
              block.call(current_subject)
            end

          end
        end
        scoreboard.day_scores[date] = scoreboard.day_score
      end
    end
  end
end
