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

      class EmptyLinkedList
        def initialize
          @head
        end
        def empty?; end
        def self.cons; end
      end
    MSG
    uml_info = UMLInfoGenerator.process_code(input)

    # Execute
    dsl = NomnomlDSLGenerator.generate_dsl(uml_info)

    # Assert
    expected_class_dsl = <<~MSG
      [<class> LinkedList |
        @id; @head; @tail |
        +initialize(head, tail); +empty?; +conj(item); #==(other); -traverse(index) |
        self.make; self.cons(head, tail)
      ]
      [<class> EmptyLinkedList |
        @head |
        +initialize; +empty? |
        self.cons
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

      module Math
        def add(num); end
        def self.sqrt(num); end
      end
    MSG
    uml_info = UMLInfoGenerator.process_code(input)

    # Execute
    dsl = NomnomlDSLGenerator.generate_dsl(uml_info)

    # Assert
    expected_module_dsl = <<~MSG
      [<module> Rake |
        +run(task_id); #on?; -show_task_output(task_id, terminal_id) |
        self.errors
      ]
      [<module> Math |
        +add(num) |
        self.sqrt(num)
      ]
    MSG
    _(dsl.modules).must_equal(expected_module_dsl)
  end

  it "returns relationships dsl (inheritence, includes, extends, prepends)" do
    # Setup
    input = <<~MSG.chomp
      class LinkedList
        include Enumerable
        extend Helpers
        prepend Bonus
      end

      class EmptyLinkedList < LinkedList; end
    MSG
    uml_info = UMLInfoGenerator.process_code(input)

    # Execute
    dsl = NomnomlDSLGenerator.generate_dsl(uml_info)

    # Assert
    expected_relationships_dsl = <<~MSG
    [LinkedList] includes <- [Enumerable]
    [LinkedList] extends <- [Helpers]
    [LinkedList] prepends <- [Bonus]
    [EmptyLinkedList] inherits <:- [LinkedList]
    MSG
    _(dsl.relationships).must_equal(expected_relationships_dsl)
  end

  it "escapes square brackets from instance methods and singleton methods" do
    # Setup
    input = <<~MSG.chomp
      class LinkedList
        def []; end
        def self.[]; end
      end

      module Math
        def []; end
        def self.[]; end
      end
    MSG
    uml_info = UMLInfoGenerator.process_code(input)

    # Execute
    dsl = NomnomlDSLGenerator.generate_dsl(uml_info)

    # Assert
    expected_class_dsl = '[<class> LinkedList |
   |
  +\[\] |
  self.\[\]
]
'
    _(dsl.classes).must_equal(expected_class_dsl)

    expected_module_dsl = '[<module> Math |
  +\[\] |
  self.\[\]
]
'
    _(dsl.modules).must_equal(expected_module_dsl)
  end
end