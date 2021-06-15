module UMLInfoGenerator
  ClassInfo = Struct.new(:name, :instance_methods)

  RelationshipInfo = Struct.new(:subject, :object, :verb) do
    def to_s
      "#{subject} #{verb} #{object}"
    end
  end

  InstanceMethodInfo = Struct.new(:name, :type, :parameters) do
    def to_s
      "#{type} #{name}(#{parameters.join(', ')})"
    end
  end

  class UMLInfo
    attr_reader :classes
    def initialize(classes, modules = [], relationships = [])
      @classes = classes
      @modules = modules
      @relationships = relationships
    end

    def class_names
      classes.map(&:name)
    end

    def relationships
      @relationships.map(&:to_s)
    end
  end
end
