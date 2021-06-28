module RubyToUML
  module UMLInfoGenerator
    module ProcessorHelpers
      private
      def instance_methods_closure
        type = :public
        lambda do |node, instance_methods_info|
          case node.type
          when :def
            method_name = NodeFinder.method_name(node)
            args        = NodeFinder.instance_method_args(node)
            instance_methods_info << InstanceMethodInfo.new(method_name, type, args)
          when :send
            method_name = NodeFinder.send_method(node)
            new_type    = NodeFinder.method_type_change(method_name)
            type = new_type if new_type
          end
        end
      end

      def singleton_methods_closure
        lambda do |node, singleton_methods_info|
          if node.type == :defs
            method_name = NodeFinder.singleton_method_name(node)
            args        = NodeFinder.singleton_method_args(node)
            singleton_methods_info << SingletonMethodInfo.new(method_name, args)
          end
        end
      end

      def instance_variables_closure
        lambda do |node, instance_variables_info|
          if node.type == :def && NodeFinder.method_name(node) == :initialize
            method_body_node = BodyNodeWrapper.new(NodeFinder.method_body_node(node))
            closure = lambda do |node|
              if node.type == :ivar || node.type == :ivasgn
                variable_name = NodeFinder.instance_variable_name(node)
                instance_variables_info << variable_name
              end
            end
            method_body_node.simple_operation(&closure)
          end
        end
      end

      def add_inheritence_relationship(class_name, superclass_name)
        relationships << RelationshipInfo.new(class_name, superclass_name, :inherits)
      end

      def add_module_relationships_if_exist_closure(class_name)
        lambda do |node|
          if node.type == :send
            _, method, module_name = *node
            if %i[include extend prepend].include? method
              verb = "#{method}s".to_sym
              add_module_relationship(class_name, module_name, verb)
            end
          end
        end
      end

      def add_module_relationship(class_name, arguments, type)
        module_name = NodeFinder.constant_name(arguments)
        relationships << RelationshipInfo.new(class_name, module_name, type)
      end
    end

    class NodeFinder
      class << self
        def class_name(node)
          constant, inherit, children = *node
          NodeFinder.constant_name(constant)
        end

        def class_body(node)
          body_node_index = 2
          node.children[body_node_index]
        end

        def superclass_name(node)
          constant, inherit, children = *node
          inherit ? NodeFinder.constant_name(inherit) : nil
        end

        def constant_name(const_node)
          constant_name_index = 1
          const_node.children[constant_name_index]
        end

        def method_name(def_node)
          name_index = 0
          def_node.children[name_index]
        end

        def instance_method_args(def_node)
          args_index = 1
          NodeFinder.arguments(def_node.children[args_index])
        end

        def send_method(send_node)
          caller, method, arguments = *send_node
          method
        end

        def method_type_change(method_name)
          %i[public private protected].include?(method_name) ? method_name : nil
        end

        def singleton_method_name(defs_node)
          name_index = 1
          defs_node.children[name_index]
        end

        def singleton_method_args(defs_node)
          args_index = 2
          NodeFinder.arguments(defs_node.children[args_index])
        end

        def arguments(node)
          return [] if node.children.nil?

          node.children.each_with_object([]) { |node, args| args << node.children[0] }
        end

        def method_body_node(def_node)
          body_index = 2
          def_node.children[body_index]
        end

        def instance_variable_name(node)
          name_index = 0
          node.children[name_index]
        end

        def module_name(node)
          constant, = *node
          NodeFinder.constant_name(constant)
        end

        def module_body(node)
          _, body = *node
          body
        end
      end
    end

    module ClassAndRelationshipsProcessor
      def on_class(node)
        class_name              = NodeFinder.class_name(node)
        superclass_name         = NodeFinder.superclass_name(node)
        class_body_node         = BodyNodeWrapper.new(NodeFinder.class_body(node))
        instance_methods_info   = class_body_node.array_operation(&instance_methods_closure)
        singleton_methods_info  = class_body_node.array_operation(&singleton_methods_closure)
        instance_variables_info = class_body_node.array_operation(&instance_variables_closure)

        add_inheritence_relationship(class_name, superclass_name) if superclass_name
        class_body_node.simple_operation(&add_module_relationships_if_exist_closure(class_name))

        add_class(class_name, instance_methods_info, singleton_methods_info, instance_variables_info)

        node.updated(nil, process_all(node))
      end

      private

      def add_class(name, instance_methods_info, singleton_methods_info, instance_variables_info)
        classes << ClassInfo.new(name, instance_methods_info, singleton_methods_info, instance_variables_info)
      end
    end

    module ModuleProcesor
      def on_module(node)
        module_name            = NodeFinder.module_name(node)
        module_body_node       = BodyNodeWrapper.new(NodeFinder.module_body(node))
        instance_methods_info  = module_body_node.array_operation(&instance_methods_closure)
        singleton_methods_info = module_body_node.array_operation(&singleton_methods_closure)

        add_module(module_name, instance_methods_info, singleton_methods_info)

        node.updated(nil, process_all(node))
      end

      private

      def add_module(name, instance_methods_info, singleton_methods_info)
        modules << ModuleInfo.new(name, instance_methods_info, singleton_methods_info)
      end
    end

    class BodyNodeWrapper
      def initialize(body_node)
        @body_node = body_node
      end

      def array_operation(&operation)
        array = []
        if body_node.nil?
          nil
        elsif body_node.type == :begin
          body_node.children.each { |node| operation.call(node, array) }
        else
          operation.call(body_node, array)
        end
        array
      end

      def simple_operation(&operation)
        if body_node.nil?
          nil
        elsif body_node.type == :begin
          body_node.children.each { |node| operation.call(node) }
        else
          operation.call(body_node)
        end
      end

      private

      attr_reader :body_node
    end
  end
end