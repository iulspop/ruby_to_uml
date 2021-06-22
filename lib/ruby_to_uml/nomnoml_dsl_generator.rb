module RubyToUML
  module NomnomlDSLGenerator
    def self.generate_dsl(uml_info)
      classes = create_class_dsl(uml_info.classes)
      modules = create_modules_dsl(uml_info.modules)
      relationships = create_relationships_dsl(uml_info.relationships)
      NomnomlDSL.new(style, classes, modules, relationships)
    end

    class << NomnomlDSLGenerator
      private

      def style
        <<~MSG
          #direction: right
          #zoom: 0.9

          #font: Roboto
          #fontSize: 20
          #leading: 2
          #padding: 12

          #fillArrows: true
          #arrowSize: 0.5
          #spacing: 130

          #lineWidth: 1.5
          #stroke: #33322E

          #.class: fill=#FEDCC4 title=bold
          #.module: fill=#D9E6FF title=bold
        MSG
      end

      def create_class_dsl(class_infos)
        class_infos.each_with_object('') do |class_info, dsl_string|
          name = class_info.name
          instance_variables = class_info.instance_variables_info.join('; ')
          instance_methods = instance_methods_dsl(class_info.instance_methods_info)
          singleton_methods = singleton_methods_dsl(class_info.singleton_methods_info)

          class_dsl = <<~MSG
            [<class> #{name} |
              #{instance_variables} |
              #{instance_methods} |
              #{singleton_methods}
            ]
          MSG

          dsl_string << class_dsl
        end
      end

      def create_modules_dsl(module_infos)
        module_infos.each_with_object('') do |module_info, dsl_string|
          name = module_info.name
          instance_methods = instance_methods_dsl(module_info.instance_methods_info)
          singleton_methods = singleton_methods_dsl(module_info.singleton_methods_info)

          module_dsl = <<~MSG
            [<module> #{name} |
              #{instance_methods} |
              #{singleton_methods}
            ]
          MSG

          dsl_string << module_dsl
        end
      end

      def create_relationships_dsl(relationship_infos)
        relationship_infos.each_with_object('') do |relationship_info, dsl_string|
          subject = relationship_info.subject
          verb = relationship_info.verb
          object = relationship_info.object

          arrow_dictionary = {
            inherits: '<:-',
            includes: '<-',
            extends: '<-',
            prepends: '<-'
          }

          arrow = arrow_dictionary[verb]

          relationship_dsl = "[#{subject}] #{verb} #{arrow} [#{object}]\n"

          dsl_string << relationship_dsl
        end
      end

      def instance_methods_dsl(method_infos)
        method_infos.map do |method_info|
          instance_method_dsl(method_info)
        end.join('; ').gsub(/\[/, '&rbrack;').gsub(/\]/, '&lbrack;')
      end

      def singleton_methods_dsl(method_infos)
        method_infos.map do |method_info|
          singleton_method_dsl(method_info)
        end.join('; ').gsub(/\[/, '&rbrack;').gsub(/\]/, '&lbrack;')
      end

      def instance_method_dsl(method_info)
        type_dictionary = {
          public: '+',
          protected: '#',
          private: '-'
        }

        type = type_dictionary[method_info.type]
        name = method_info.name
        arguments = method_info.parameters

        arguments = arguments.empty? ? '' : "(#{arguments.join(', ')})"

        "#{type}#{name}#{arguments}"
      end

      def singleton_method_dsl(method_info)
        name = method_info.name
        arguments = method_info.parameters

        arguments = arguments.empty? ? '' : "(#{arguments.join(', ')})"

        "self.#{name}#{arguments}"
      end
    end

    NomnomlDSL = Struct.new(:style, :classes, :modules, :relationships) do
      def to_s
        style + classes + modules + relationships
      end
    end
  end
end
