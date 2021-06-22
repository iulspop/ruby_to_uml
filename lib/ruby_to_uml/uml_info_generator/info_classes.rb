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
    :singleton_methods_info
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
    attr_reader :classes, :modules, :relationships

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
      classes.map(&:instance_variables_info)
    end

    def relationship_descriptions
      relationships.map(&:to_s)
    end

    def merge(other_uml_info)
      unique_relationships = (relationships + other_uml_info.relationships).uniq
      unique_classes = merge_classes(classes, other_uml_info.classes)
      unique_modules = merge_modules(modules, other_uml_info.modules)
      UMLInfo.new(unique_classes, unique_modules, unique_relationships)
    end

    private

    def merge_classes(classes, other_classes)
      merge_entities(classes, other_classes, &merge_class_attributes(classes))
    end

    def merge_modules(modules, other_modules)
      merge_entities(modules, other_modules, &merge_module_attributes(modules))
    end

    def merge_entities(group, other_group, &merge_attributes)
      unique_entities = []
      merged = []

      distinct_entities = (group + other_group).uniq

      distinct_entities.each do |entity_1|
        next if merged.include?(entity_1.name)

        matched_entities = []
        distinct_entities.each do |entity_2|
          matched_entities << entity_2 if entity_1.name == entity_2.name && entity_1.object_id != entity_2.object_id
        end

        if matched_entities.empty?
          unique_entities << entity_1
        else
          unique_entities << merge_attributes.call([entity_1, *matched_entities])
          merged << entity_1.name
        end
      end

      unique_entities
    end

    def merge_class_attributes(classes)
      getters = %i[instance_methods_info singleton_methods_info instance_variables_info]
      merge_attributes(classes, getters)
    end

    def merge_module_attributes(classes)
      getters = %i[instance_methods_info singleton_methods_info]
      merge_attributes(classes, getters)
    end

    def merge_attributes(_objects, getters)
      lambda do |objects|
        example_object = objects[0]

        uniq_attributes = []
        getters.each do |getter|
          attribute = []
          objects.each do |object|
            object.send(getter)
            attribute << object.send(getter)
          end
          uniq_attributes << attribute.flatten.uniq
        end

        klass = example_object.class
        klass.new(example_object.name, *uniq_attributes)
      end
    end
  end
end
