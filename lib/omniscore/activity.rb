class Activity
  attr_reader :type
  attr_reader :date

  attr_reader :subject_id
  attr_reader :subject_type


  def initialize(activity_type, subject, date)
    @subject_id     = subject.id
    @activity_type  = activity_type.to_sym
    @date           = date
  end
end