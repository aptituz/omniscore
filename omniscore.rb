#!/usr/bin/env ruby

require 'rubygems'
require 'pry'
require 'json'
require "rubyfocus"

class Score
  attr_reader :task_id
  attr_reader :score

  def initialize(task_id, score)
    @task_id = task_id
    @score   = score
  end

  def when(result)
    if result
      OmniScore.track_score(task_id, score)
    end
  end
end

class ScoringRules
  attr_reader :score
  attr_accessor :task
  attr_accessor :rulefile

  def initialize(rulefile)
    load_rules(rulefile)
  end

  def in_project(name)
    ancestors.any? { |ancestor|  ancestor.kind_of?(Rubyfocus::Project) and ancestor.name == name }
  end

  def in_folder(name)
    ancestors.any? { |ancestor|  ancestor.kind_of?(Rubyfocus::Folder) and ancestor.name == name }
  end

  def name_contains(pattern)
    task.name.include?(pattern)
  end

  def ancestors
    if block_given?
      task.ancestry.each do |ancestor|
        yield(ancestor)
      end
    else
      return task.ancestry
    end
  end

  def score(score)
    Score.new(task.id, score)
  end


  def load_rules(rulefile)
    puts "Loading rules from #{rulefile}"
    @rules = File.read(rulefile)
  end

  def run_rules(tasks)
    # FIXME: Rules should run against subtasks, too
    tasks.each do |task|
      @task = task
      instance_eval(@rules)
    end
  end
end

class OmniScore
  attr_reader :document
  attr_reader :score

  @@scores ||= {}

  def document
    @document ||= OmniScore.omnifocus_document
  end

  def rulefile
    'rules.rb'
  end

  def outfile
    'scoreboard.json'
  end

  def completed_tasks
    document.tasks.select(completed?: true).select do |task|
      task.completed.to_date >= (Date.today - 30)
    end
  end

  def task_by_id(task_id)
    document.tasks.select(id: task_id).first
  end

  def run
    rule = ScoringRules.new(rulefile)
    rule.run_rules(completed_tasks)
    scoreboard = build_scoreboard
    File.open(outfile, 'w') { |f| f.write scoreboard.to_json }
    puts "Written scoreboard to #{outfile}."

  end

  def build_scoreboard
    scoreboard = { :by_date => {}, :highscore => 0 }
    @@scores.each do |task_id, score|
      completion_date = task_by_id(task_id).completed.to_date
      scoreboard[:by_date][completion_date] ||= 0
      scoreboard[:by_date][completion_date] += score
    end
    scoreboard[:day_scores] = scoreboard[:by_date].sort_by { |date,score| date }.map { |date, score| [date.day,score] }
    scoreboard[:highscore] = scoreboard[:by_date].map { |date,score| score }.max

    puts "Highscore: #{scoreboard[:highscore]}"
    scoreboard
  end

  def self.omnifocus_document
    document = nil
    if File.exist?('ofocus.yaml')
      document = Rubyfocus::Document.load_from_file("ofocus.yaml")
    else
      fetcher = Rubyfocus::LocalFetcher.new
      document =Rubyfocus::Document.new(fetcher)
    end
    document.update
    document
  end

  def self.track_score(task_id, score)
    @@scores[task_id] = score
  end
end


app = OmniScore.new
app.run
