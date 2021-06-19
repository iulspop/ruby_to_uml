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
      unique_relationships = (relationships + other_uml_info.relationships).uniq
      unique_classes = merge_classes(classes, other_uml_info.classes)
      UMLInfo.new(unique_classes, [], unique_relationships)
    end

    protected

    attr_reader :classes, :modules, :relationships

    private

    def merge_classes(classes, other_classes)
      unique_classes = []
      merged = []

      distinct_classes = (classes + other_classes).uniq

      distinct_classes.each do |class_1|
        next if merged.include?(class_1.name)

        matched_classes = []
        distinct_classes.each do |class_2|
          if class_1.name == class_2.name && class_1.object_id != class_2.object_id
            matched_classes << class_2
          end
        end

        unless matched_classes.empty?
          unique_classes << merge_class_attributes([class_1, *matched_classes])
          merged << class_1.name
        else
          unique_classes <<class_1 
        end
      end

      unique_classes
    end

    def merge_class_attributes(classes)
      getters = [:instance_methods_info, :singleton_methods_info, :instance_variables_info]
      merge_attributes(classes, getters)
    end

    def merge_attributes(objects, getters)
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
