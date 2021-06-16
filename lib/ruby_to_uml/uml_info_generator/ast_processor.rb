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

      wrapped_body_node = BodyNodeWrapper.new(class_body_node)
      instance_methods_info = wrapped_body_node.array_operation(&get_instance_methods_closure)
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

    def get_instance_methods_closure
      type = :public
      lambda do |node, instance_methods_info|
        if node.type == :def
          method_name = get_method_name(node)
          args        = get_instance_method_args(node)
          instance_methods_info << InstanceMethodInfo.new(method_name, type, args)
        elsif node.type == :send
          method_name = get_send_method(node)
          new_type    = get_method_type_change(method_name)
          type = new_type if new_type
        end
      end
    end

    def get_arguments(node)
      return [] if node.children.nil?
      node.children.each_with_object([]) { |node, args| args << node.children[0] }
    end

    def get_singleton_methods(node)
      if node.type == :begin
        singleton_methods_info = []
        node.children.each do |node|
          if node.type == :defs
            method_name = get_singleton_method_name(node)
            args        = get_singleton_method_args(node)
            singleton_methods_info << SingletonMethodInfo.new(method_name, args)
          end
        end
        return singleton_methods_info
      else
        singleton_methods_info = []
        if node.type == :defs
          method_name = get_singleton_method_name(node)
          args        = get_singleton_method_args(node)
          singleton_methods_info << SingletonMethodInfo.new(method_name, args)
        end
        return singleton_methods_info
      end
    end

    def add_class(name, instance_methods_info, singleton_methods_info)
      classes << ClassInfo.new(name.to_s, instance_methods_info, singleton_methods_info)
    end

    def get_constant_name(const_node)
      # Unscoped Constant form: (const nil :ConstantName)
      # nil represents no scope, could be scoped to another constant
      constant_name_index = 1
      const_node.children[constant_name_index]
    end

    def get_method_name(def_node)
      name_index = 0
      def_node.children[name_index]
    end

    def get_instance_method_args(def_node)
      args_index = 1
      get_arguments(def_node.children[args_index])
    end

    def get_send_method(send_node)
      caller, method, arguments = *send_node
      method
    end

    def get_method_type_change(method_name)
      [:public, :private, :protected].include?(method_name) ? method_name : nil
    end

    def get_singleton_method_name(defs_node)
      name_index = 1
      defs_node.children[name_index]
    end

    def get_singleton_method_args(defs_node)
      args_index = 2
      get_arguments(defs_node.children[args_index])
    end
  end

  class BodyNodeWrapper
    def initialize(body_node)
      @body_node = body_node
    end

    def array_operation(&operation)
      array = []
      if body_node.type == :begin
        body_node.children.each { |node| operation.call(node, array) }
      else
        operation.call(body_node, array)
      end
      array
    end

    private

    attr_reader :body_node
  end
end
