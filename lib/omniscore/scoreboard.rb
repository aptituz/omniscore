class Omniscore
  class Scoreboard
    include Singleton

    attr_accessor :day_score
    attr_accessor :day_scores
    attr_accessor :total_score

    def initialize
      @day_score    = 0
      @day_scores   = {}
      @total_score  = 0
    end

    def highscore
      @highscore ||= day_scores.map { |date,score| score }.max
    end

    def summary
      puts "Total score: #{total_score}"
      puts "Highest day score: #{highscore}"

    end

    def dump_to_file(filename)
      scoreboard = { :by_date => {}, :highscore => 0 }

      scoreboard[:by_date] = day_scores
      scoreboard[:day_scores] = scoreboard[:by_date].sort_by { |date,score| date }.map { |date, score| [date.day,score] }
      scoreboard[:highscore] = scoreboard[:by_date].map { |date,score| score }.max

      File.open(filename, 'w') { |f| f.write(scoreboard.to_json) }
    end

  end
end