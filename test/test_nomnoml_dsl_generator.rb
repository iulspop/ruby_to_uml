require_relative '../lib/ruby_to_uml'

describe "NomnomlDSLGenerator" do
  it "returns classes formated with name, instance variables, instance methods and singleton methods" do
    # Setup
    input = <<~MSG.chomp
      class LinkedList
        def initialize(head, tail)
          @id
          @head = head
          @tail = tail
        end
        def empty?; end
        def conj(item); end
        protected
        def ==(other); end
        private
        def traverse(index); end
        def self.make; end
        def self.cons(head, tail); end
      end
    MSG
    uml_info = UMLInfoGenerator.process_code(input)

    # Execute
    dsl = NomnomlDSLGenerator.generate_dsl(uml_info)

    # Assert
    expected_class_dsl = <<~MSG
      [<class>
        LinkedList |
        @id; @head; @tail |
        +initialize(head, tail); +empty?; +conj(item); #==(other); -traverse(index) |
        self.make; self.cons(head, tail)
      ]
    MSG
    _(dsl.classes).must_equal(expected_class_dsl)
  end

  it "returns modules formated with name, instance methods and singleton methods" do
    # Setup
    input = <<~MSG.chomp
      module Rake
        def run(task_id); end
        protected
        def on?; end
        private
        def show_task_output(task_id: nil, terminal_id: nil); end
        def self.errors; end
      end
    MSG
    uml_info = UMLInfoGenerator.process_code(input)

    # Execute
    dsl = NomnomlDSLGenerator.generate_dsl(uml_info)

    # Assert
    expected_module_dsl = <<~MSG
      [<module>
        Rake |
        +run(task_id); #on?; -show_task_output(task_id, terminal_id) |
        self.errors
      ]
    MSG
    _(dsl.modules).must_equal(expected_module_dsl)
  end
end