class Omniscore
  module Matchers
    def subject
      Omniscore::Runner.current_subject
    end

    def in_project(name)
      MatchObject.new('in_project', name, subject) do |subject|
        subject.ancestry.any? { |ancestor|  ancestor.kind_of?(Rubyfocus::Project) and ancestor.name == name }
      end
    end

    def in_folder(name)
      MatchObject.new('in_folder', name, subject) do |subject|
        subject.ancestry.any? { |ancestor|  ancestor.kind_of?(Rubyfocus::Folder) and ancestor.name == name }
      end
    end

    def name_contains(pattern)
      MatchObject.new('name_contains', pattern, subject) do |subject|
        subject.name.include?(pattern)
      end
    end
  end
end
