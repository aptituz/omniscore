on_added_project do |project|
  add_score 1
end

on_added_task do
  add_score 1
end

on_completed_task do |task|
  add_score 1

  # Some extra points for organisation tasks
  add_score 15, :if =>  name_contains('Weekly Review')    and next
  add_score 3,  :if =>  name_contains('Daily Review')     and next

  add_score 10, :if => in_project("Hausarbeit")           and next
  add_score  5, :if => name_contains('wasch')             and next
  add_score 15, :if => name_contains('Toilette putzen')   and next
  add_score  2, :if => name_contains('Spülmaschine')      and next
end

on_completed_project do |project|
  add_score 5
end

on_reviewed_project do |project|
  add_score 2
end

define_streak :days => 3,   :score => 1
define_streak :days => 5,   :score => 2
define_streak :days => 10,  :score => 10
define_streak :days => 20,  :score => 50