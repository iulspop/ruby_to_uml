module NomnomlDSLGenerator
  def self.generate_dsl(uml_info)
    classes = create_class_dsl(uml_info.classes)
    NomnomlDSL.new(style, classes)
  end

  class << NomnomlDSLGenerator
    private
    def style
      <<~MSG.chomp
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
      class_infos.each_with_object("") do |class_info, dsl_string|
        name = class_info.name
        instance_variables = class_info.instance_variables_info.join("; ")
        instance_methods = class_info.instance_methods_info.map do |method_info|
          instance_method_dsl(method_info)
        end.join("; ")
        singleton_methods = class_info.singleton_methods_info.map do |method_info|
          singleton_method_dsl(method_info)
        end.join("; ")

        class_dsl = <<~MSG.chomp
          [<class>
            #{name} |
            #{instance_variables} |
            #{instance_methods} |
            #{singleton_methods}
          ]
        MSG

        dsl_string << class_dsl
      end
    end

    def instance_method_dsl(method_info)
      type_dictionary = {
        public: "+",
        protected: "#",
        private: "-"
      }

      type = type_dictionary[method_info.type]
      name = method_info.name
      arguments = method_info.parameters

      arguments.empty? ? arguments = '' : arguments = "(#{arguments.join(", ")})"

      "#{type}#{name}#{arguments}"
    end

    def singleton_method_dsl(method_info)
      name = method_info.name
      arguments = method_info.parameters

      arguments.empty? ? arguments = '' : arguments = "(#{arguments.join(", ")})"

      "self.#{name}#{arguments}"
    end
  end

  NomnomlDSL = Struct.new(:style, :classes, :modules, :relationships)
end

expected_class_dsl = <<~MSG.chomp
  [<class>
    LinkedList |
    @id; @head; @tail |
    +conj(item); +empty?; #==(other); -traverse(index) |
    self.make(args); self.cons(head, tail)
  ]
MSG