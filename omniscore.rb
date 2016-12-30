#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'pry'
require 'rubygems'
require 'json'
require "rubyfocus"

require 'omniscore'


class Omniscore


  def rulefile
    'rules.rb'
  end

  def outfile
    'scoreboard.json'
  end

  def runner
    @runner ||= Omniscore::Runner.(activities, scoring_rules)
  end

  def scoreboard
    Omniscore::Scoreboard.instance
  end

  def activities
    @activities ||= Activities.from_omnifocus_document(document)
  end

  def document
    @document ||= Omniscore.omnifocus_document
  end

  def scoring_rules
    @scoring_rules ||= Omniscore::DSL.eval_rules
  end

  def self.debug
    false
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

  def run
    Omniscore::Runner.process(activities, scoring_rules)
    scoreboard.summary
    scoreboard.dump_to_file(outfile)
  end

end


app = Omniscore.new
app.run
