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
      expected = %i[Stack LinkedList EmptyLinkedList]
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
      _(uml_info.class_instance_methods).must_equal(expected)
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
      _(uml_info.class_singleton_methods).must_equal(expected)
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
      _(uml_info.class_instance_methods).must_equal(expected)
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
      _(uml_info.class_singleton_methods).must_equal(expected)
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
      _(uml_info.class_instance_variables).must_equal(expected)
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
      _(uml_info.class_instance_variables).must_equal(expected)
    end
  end

  describe 'module info' do
    it "returns name of every module" do
      # Setup
      input = <<~MSG.chomp
        module Enumerable; end

        module Rake
          module TaskRunner; end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = %i[Enumerable Rake TaskRunner]
      _(uml_info.module_names).must_equal(expected)
    end

    it "returns instance methods with correct type and arguments" do
      # Setup
      input = <<~MSG.chomp
        module Rake
          def run(task_id); end
          protected
          def on?; end
          private
          def show_task_output(task_id: nil, terminal_id: nil); end
        end
      MSG
  
      # Execute
      uml_info = UMLInfoGenerator.process_code(input)
  
      # Assert
      instance_methods = <<~MSG.chomp
        public run(task_id)
        protected on?()
        private show_task_output(task_id, terminal_id)
      MSG
      expected = [instance_methods]
      _(uml_info.module_instance_methods).must_equal(expected)
    end

    it "returns singleton methods with arguments and without type" do
      # Setup
      input = <<~MSG.chomp
        module Math
          def self.sqrt(number); end
          def self.pi; end
          private
          def self.to_fixed_point; end
        end
      MSG
  
      # Execute
      uml_info = UMLInfoGenerator.process_code(input)
  
      # Assert
      singleton_methods = <<~MSG.chomp
        self.sqrt(number)
        self.pi()
        self.to_fixed_point()
      MSG
      expected = [singleton_methods]
      _(uml_info.module_singleton_methods).must_equal(expected)
    end

    it "returns instance methods even when class body has a single node" do
      # Setup
      input = <<~MSG.chomp
        module Rake
          def run(task_id); end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["public run(task_id)"]
      _(uml_info.module_instance_methods).must_equal(expected)
    end

    it "returns singleton methods even when class body has a single node" do
      # Setup
      input = <<~MSG.chomp
        module Math
          def self.sqrt(number); end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_code(input)

      # Assert
      expected = ["self.sqrt(number)"]
      _(uml_info.module_singleton_methods).must_equal(expected)
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
      _(uml_info.relationship_descriptions).must_equal(expected)
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
      _(uml_info.relationship_descriptions).must_equal(expected)
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
      _(uml_info.relationship_descriptions).must_equal(expected)
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
      _(uml_info.relationship_descriptions).must_equal(expected)
    end
  end
end
