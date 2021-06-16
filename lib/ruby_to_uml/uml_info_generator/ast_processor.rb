module UMLInfoGenerator
  class ASTProcessor < Parser::AST::Processor
    attr_reader :classes, :relationships

    def initialize
      @classes = []
      @relationships = []
    end

    def on_class(node)
      # Class definition form:
      # first child is class name constant,
      # second child is superclass constant or nil,
      # third child is the class body
      # body is either begin type with children nodes, or a single node of any type
      class_name             = get_class_name(node)
      superclass_name        = get_superclass_name(node)
      class_body_node        = get_class_body(node)
      instance_methods_info  = get_instance_methods(class_body_node)
      singleton_methods_info = get_singleton_methods(class_body_node)

      add_inheritence_relationship(class_name, superclass_name) if superclass_name
      add_module_relationships_if_exist(class_body_node, class_name)
      add_class(class_name, instance_methods_info, singleton_methods_info)

      node.updated(nil, process_all(node))
    end

    private

    def get_class_name(node)
      constant, inherit, children = *node
      get_constant_name(constant)
    end

    def get_class_body(node)
      body_node_index = 2
      node.children[body_node_index]
    end

    def get_superclass_name(node)
      constant, inherit, children = *node
      inherit ? get_constant_name(inherit) : nil
    end

    def add_inheritence_relationship(class_name, superclass_name)
      relationships << RelationshipInfo.new(class_name, superclass_name, :inherits)
    end

    def add_module_relationships_if_exist(node, class_name)
      operation = lambda do |node|
        return if node.type != :send
        caller, method, arguments = *node
        case method
        when :include then add_module_relationship(class_name, arguments, :includes)
        when :extend  then add_module_relationship(class_name, arguments, :extends)
        when :prepend then add_module_relationship(class_name, arguments, :prepends) end
      end
      operate(node, &operation)
    end

    def operate(node, &operation)
      if node.type == :begin
        node.children.each { |node| operation.call(node) }
      else
        operation.call(node)
      end
    end

    def add_module_relationship(class_name, arguments, type)
      module_name = get_constant_name(arguments)
      relationships << RelationshipInfo.new(class_name, module_name, type)
    end

    def get_instance_methods(node)
      if node.type == :begin
        type = :public
        node.children.each_with_object([]) do |node, instance_methods_info|
          if node.type == :def
            name = node.children[0]
            args = get_arguments(node.children[1])
            instance_methods_info << InstanceMethodInfo.new(name, type, args)
          elsif node.type == :send
            caller, method, arguments = *node
            case method
            when :public    then type = :public
            when :private   then type = :private
            when :protected then type = :protected end
          end
        end
      else
        if node.type == :def
          name = node.children[0]
          args = get_arguments(node.children[1])
          return [InstanceMethodInfo.new(name, :public, args)]
        else
          []
        end
      end
    end

    def get_arguments(node)
      return [] if node.children.nil?
      node.children.each_with_object([]) { |node, args| args << node.children[0] }
    end

    def get_singleton_methods(node)
      if node.type == :begin
        node.children.each_with_object([]) do |node, singleton_methods_info|
          if node.type == :defs
            name = node.children[1]
            args = get_arguments(node.children[2])
            singleton_methods_info << SingletonMethodInfo.new(name, args)
          end
        end
      else
        if node.type == :defs
          name = node.children[1]
          args = get_arguments(node.children[2])
          return [SingletonMethodInfo.new(name, args)]
        else
          []
        end
      end
    end

    def add_class(name, instance_methods_info, singleton_methods_info)
      classes << ClassInfo.new(name.to_s, instance_methods_info, singleton_methods_info)
    end

    def get_constant_name(constant)
      # Unscoped Constant form: (const nil :ConstantName)
      # nil represents no scope, could be scoped to another constant
      constant_name_index = 1
      constant.children[constant_name_index]
    end
  end
end
