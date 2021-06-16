require_relative '../lib/ruby_to_uml'

describe UMLInfoGenerator do
  describe 'class info' do
    it "returns name of every class" do
      # Setup
      input = <<~MSG.chomp
        class Stack
        end

        class LinkedList

          class EmptyLinkedList

          end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = %w[Stack LinkedList EmptyLinkedList]
      _(uml_info.class_names).must_equal(expected)
    end

    it "returns instance methods with correct type and arguments" do
      # Setup
      input = <<~MSG.chomp
        class LinkedList
          def conj(item); end
          def empty?; end
          protected
          def ==(other); end
          private
          def traverse(index); end
        end
      MSG
  
      # Execute
      uml_info = UMLInfoGenerator.process_code(input)
  
      # Assert
      instance_methods = <<~MSG.chomp
        public conj(item)
        public empty?()
        protected ==(other)
        private traverse(index)
      MSG
      expected = [instance_methods]
      _(uml_info.instance_methods).must_equal(expected)
    end

    it "returns singleton methods with arguments and without type" do
      # Setup
      input = <<~MSG.chomp
        class LinkedList
          def self.conj(item); end
          def empty?; end
          protected
          def self.==(other); end
          private
          def self.traverse(index); end
        end
      MSG
  
      # Execute
      uml_info = UMLInfoGenerator.process_code(input)
  
      # Assert
      singleton_methods = <<~MSG.chomp
        self.conj(item)
        self.==(other)
        self.traverse(index)
      MSG
      expected = [singleton_methods]
      _(uml_info.singleton_methods).must_equal(expected)
    end

    it "returns instance methods even when class body has a single node" do
      # Setup
      input = <<~MSG.chomp
        class Turtle
          def yellow(iron)

          end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["public yellow(iron)"]
      _(uml_info.instance_methods).must_equal(expected)
    end

    it "returns singleton methods even when class body has a single node" do
      # Setup
      input = <<~MSG.chomp
        class Turtle
          def self.yellow(iron)

          end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["self.yellow(iron)"]
      _(uml_info.singleton_methods).must_equal(expected)
    end

    it "returns instance variables defined in the initialize method body" do
      # Setup
      input = <<~MSG.chomp
        class Animal
          def initialize(name, age)
            @family
            @name = name
            @age = age
          end

          def bark(sound)
            @sound = sound
            puts sound
          end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = [%i[@family @name @age]]
      _(uml_info.instance_variables).must_equal(expected)
    end

    it "returns instance variables even if initialize method has one node" do
      # Setup
      input = <<~MSG.chomp
        class Animal
          def initialize
            @name
          end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = [%i[@name]]
      _(uml_info.instance_variables).must_equal(expected)
    end
  end

  describe 'relationships info' do
    it "returns inheritence relationships" do
      input = <<~MSG.chomp
        class EmptyLinkedList < LinkedList
          class Stack < Heap; end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["EmptyLinkedList inherits LinkedList", "Stack inherits Heap"]
      _(uml_info.relationships).must_equal(expected)
    end

    it "returns include relationships" do
      # Setup
      input = <<~MSG.chomp
        class LinkedList
          include Enumerable
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["LinkedList includes Enumerable"]
      _(uml_info.relationships).must_equal(expected)
    end

    it "returns extend relationships" do
      # Setup
      input = <<~MSG.chomp
        class LinkedList
          extend Utils
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["LinkedList extends Utils"]
      _(uml_info.relationships).must_equal(expected)
    end

    it "returns prepend relationships" do
      # Setup
      input = <<~MSG.chomp
        class Stack
          prepend Extras
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["Stack prepends Extras"]
      _(uml_info.relationships).must_equal(expected)
    end
  end
end
