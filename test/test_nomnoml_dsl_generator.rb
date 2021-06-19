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
    expected_class_dsl = <<~MSG.chomp
      [<class>
        LinkedList |
        @id; @head; @tail |
        +initialize(head, tail); +empty?; +conj(item); #==(other); -traverse(index) |
        self.make; self.cons(head, tail)
      ]
    MSG
    _(dsl.classes).must_equal(expected_class_dsl)
  end
end