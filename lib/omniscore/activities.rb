require 'omniscore/activity'

class Activities < Hash

  def each_date
    sort_by { |date,activities| date }.each
  end

  def add_activity(activity)
    self[activity.date] ||= []
    self[activity.date] << activity
  end

  def self.from_omnifocus_document(document)
    activities = Activities.new
    %w{task project}.each do |object_type|
      collection_name = "#{object_type}s"
      document.send(collection_name).each do |item|
        activities.add_activity(Activity.new("#{object_type}_added", item, item.added.to_date))

        if item.completed?
          activities.add_activity(Activity.new("#{object_type}_completed", item, item.added.to_date))
        end

        if item.respond_to?(:last_review) and !item.last_review.nil?
          activities.add_activity(Activity.new("#{object_type}_review", item, item.last_review.to_date))
        end
      end
    end
    activities
  end
end