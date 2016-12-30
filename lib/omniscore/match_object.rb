class MatchObject
  attr_reader :type
  attr_reader :match
  attr_reader :subject
  attr_reader :needle

  @match = false

  def initialize(type, needle, subject, &block)
    @type     = type
    @needle   = needle
    @match    = block.call(subject)
    @subject  = subject
  end

  def match?
    if match
      puts "rule #{type}(#{needle}) matched on #{subject}" if Omniscore.debug
      return true
    end
    false
  end

end