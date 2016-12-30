class Omniscore
  module Runner
    def self.current_subject
      @@current_subject
    end

    def self.set_current_subject(subject)
      @@current_subject = subject
    end

    def self.current_streak
      @@current_streak ||= 0
    end

    def self.increase_current_streak
      @@current_streak = current_streak + 1
    end

    def self.reset_current_streak
      @@current_streak = 0
    end

    def self.last_date
      @@last_date ||= nil
    end

    def self.set_last_date(date)
      @@last_date = date
    end

    def self.scoreboard
      Omniscore::Scoreboard.instance
    end

    def self.detect_streak(current_date, scoring_rules)
      if Omniscore::Runner.last_date
        last_date = Omniscore::Runner.last_date
        if current_date == last_date.next_day
          increase_current_streak
          puts "In running streak (for #{current_streak} days)" if Omniscore.debug
          if scoring_rules.streak_rules.has_key?(current_streak)
            scoreboard.add_score(scoring_rules.streak_rules[current_streak])
            puts "This streak is worth #{scoring_rules.streak_rules[current_streak]}"  if Omniscore.debug
          end
        else
          puts "Streak finished on day #{current_streak}"  if Omniscore.debug
          reset_current_streak
        end
      end
      Omniscore::Runner.set_last_date(current_date)
    end

    def self.process(activities, scoring_rules)
      activities.sort_by { |date,activities| date }.each do |date,day_activities|
        scoreboard.day_score    = 0
        Omniscore::Runner.detect_streak(date, scoring_rules)

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
