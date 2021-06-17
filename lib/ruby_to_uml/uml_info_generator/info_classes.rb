module UMLInfoGenerator
  ClassInfo = Struct.new(
    :name,
    :instance_methods_info,
    :singleton_methods_info,
    :instance_variables_info
  )

  ModuleInfo = Struct.new(
    :name,
    :instance_methods_info,
    :singleton_methods_info,
  )

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

  SingletonMethodInfo = Struct.new(:name, :parameters) do
    def to_s
      "self.#{name}(#{parameters.join(', ')})"
    end
  end

  class UMLInfo
    def initialize(classes, modules, relationships)
      @classes = classes
      @modules = modules
      @relationships = relationships
    end

    def class_names
      classes.map(&:name)
    end

    def module_names
      modules.map(&:name)
    end

    def class_instance_methods
      classes.map { |class_info| class_info.instance_methods_info.map(&:to_s).join("\n") }
    end

    def module_instance_methods
      modules.map { |class_info| class_info.instance_methods_info.map(&:to_s).join("\n") }
    end

    def class_singleton_methods
      classes.map { |class_info| class_info.singleton_methods_info.map(&:to_s).join("\n") }
    end

    def module_singleton_methods
      modules.map { |class_info| class_info.singleton_methods_info.map(&:to_s).join("\n") }
    end

    def class_instance_variables
      classes.map { |class_info| class_info.instance_variables_info }
    end

    def relationship_descriptions
      relationships.map(&:to_s)
    end

    def merge(other_uml_info)
      unique_relationships = (other_uml_info.relationships + relationships).uniq
      UMLInfo.new([], [], unique_relationships)
    end

    protected

    attr_reader :classes, :modules, :relationships
  end
end
