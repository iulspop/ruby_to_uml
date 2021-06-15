module UMLInfoGenerator
  ClassInfo = Struct.new(:name)

  RelationshipInfo = Struct.new(:subject, :object, :verb) do
    def to_s
      "#{subject} #{verb} #{object}"
    end
  end

  class UMLInfo
    def initialize(classes, modules = [], relationships = [])
      @classes = classes
      @modules = modules
      @relationships = relationships
    end

    def classes
      @classes.map(&:name)
    end

    def relationships
      @relationships.map(&:to_s)
    end
  end
end
