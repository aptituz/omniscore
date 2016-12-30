require 'omniscore/activity'

class Activities < Hash

  attr_reader :document


  def initialize(omnifocus_document)
    @document = omnifocus_document
  end

  def each_date
    sort_by { |date,activities| date }.each
  end

  def add_activity(activity)
    self[activity.date] ||= []
    self[activity.date] << activity
  end

  def subject_for(activity)
    subject_id = activity.subject_id
    case activity.subject_type.to_s
      when "Rubyfocus::Task"
        document.tasks.select(id: subject_id).first
      when "Rubyfocus::Project"
        document.projects.select(id: subject_id).first
    end
  end

  def self.from_omnifocus_document(document)
    activities = Activities.new(document)
    %w{task project}.each do |object_type|
      collection_name = "#{object_type}s"
      document.send(collection_name).each do |item|
        activities.add_activity(Activity.new("added_#{object_type}", item, item.added.to_date))

        if item.completed?
          activities.add_activity(Activity.new("completed_#{object_type}", item, item.added.to_date))
        end

        if item.respond_to?(:last_review) and !item.last_review.nil?
          activities.add_activity(Activity.new("reviewed_#{object_type}", item, item.last_review.to_date))
        end
      end
    end
    activities
  end
end