require_relative '../lib/ruby_to_uml'

describe UMLInfoGenerator do
  describe 'when processing multiple code snippets' do
    it 'returns only unique relationships (duplicates are removed)' do
      # Setup
      code1 = <<~MSG.chomp
        class EmptyLinkedList < LinkedList
          include Enumerable
          prepend Extras
          extend Abstract
        end
      MSG

      code2 = <<~MSG.chomp
        class EmptyLinkedList < LinkedList
          include Enumerable
          prepend Extras
          extend Abstract
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected = [
        "EmptyLinkedList inherits LinkedList",
        "EmptyLinkedList includes Enumerable",
        "EmptyLinkedList prepends Extras",
        "EmptyLinkedList extends Abstract"
      ]
      _(uml_info.relationship_descriptions).must_equal(expected)
    end

    it 'returns only unique classes' do
     # Setup
      code1 = <<~MSG.chomp
        class LinkedList
          class EmptyLinkedList; end
        end
      MSG

      code2 = <<~MSG.chomp
        class LinkedList
          protected
          def ==(other); end

          class EmptyLinkedList; end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected = %i[LinkedList EmptyLinkedList]
      _(uml_info.class_names).must_equal(expected)
    end

    it 'merges the instance methods of duplicate classes into a single class' do
     # Setup
      code1 = <<~MSG.chomp
        class LinkedList
          def conj(item); end

          protected
          def ==(other); end

          private
          def traverse(index); end
        end
      MSG

      code2 = <<~MSG.chomp
        class LinkedList
          def splice(index); end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected_instance_methods = <<~MSG.chomp
        public conj(item)
        protected ==(other)
        private traverse(index)
        public splice(index)
      MSG
      _(uml_info.class_instance_methods).must_equal( [expected_instance_methods] )
    end

    it 'merges the singleton methods of duplicate classes into a single class' do
     # Setup
      code1 = <<~MSG.chomp
        class LinkedList
          def self.count; end
        end
      MSG

      code2 = <<~MSG.chomp
        class LinkedList
          def self.rotate(list); end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected_singleton_methods = <<~MSG.chomp
        self.count()
        self.rotate(list)
      MSG
      _(uml_info.class_singleton_methods).must_equal( [expected_singleton_methods] )
    end

    it 'merges the instance variables of duplicate classes into a single class' do
     # Setup
      code1 = <<~MSG.chomp
        class LinkedList
          def initialize(previous_node, next_node)
            @previous_node = previous_node
            @next_node = next_node
          end
        end
      MSG

      code2 = <<~MSG.chomp
        class LinkedList
          def initialize(previous_node, next_node)
            @size
          end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected_instance_variables = [%i[@previous_node @next_node @size]]
      _(uml_info.class_instance_variables).must_equal(expected_instance_variables)
    end

    it 'when multiple duplicate classes in a single file' \
       'it merges instance methods correctly' do
      # Setup
      code1 = <<~MSG.chomp
        class LinkedList
          def conj(item); end

          protected
          def ==(other); end

          private
          def traverse(index); end
        end

        class LinkedList
          def rotate; end
        end
      MSG

      code2 = <<~MSG.chomp
        class LinkedList
          def splice(index); end
        end

        class LinkedList
          def to_array(); end
        end

        class LinkedList
          def to_symbol(); end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected_instance_methods = <<~MSG.chomp
        public conj(item)
        protected ==(other)
        private traverse(index)
        public rotate()
        public splice(index)
        public to_array()
        public to_symbol()
      MSG
      _(uml_info.class_instance_methods).must_equal( [expected_instance_methods] )
    end

    it 'returns only unique modules' do
      # Setup
      code1 = <<~MSG.chomp
        module Enumerable; end

        module Rake
          module TaskRunner; end
        end
      MSG

      code2 = <<~MSG.chomp
        module Math; end

        module Rake
          module TaskRunner; end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected = %i[Enumerable Rake TaskRunner Math]
      _(uml_info.module_names).must_equal(expected)
    end

    it 'merges the instance methods of duplicate modules into a single module' do
      # Setup
      code1 = <<~MSG.chomp
        module Rake
          def run(task_id); end
          protected
          def on?; end
        end
      MSG

      code2 = <<~MSG.chomp
        module Rake
          private
          def show_task_output(task_id: nil, terminal_id: nil); end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected_instance_methods = <<~MSG.chomp
        public run(task_id)
        protected on?()
        private show_task_output(task_id, terminal_id)
      MSG
      _(uml_info.module_instance_methods).must_equal([expected_instance_methods])
    end

    it 'merges the singleton methods of duplicate modules into a single module' do
      # Setup
      code1 = <<~MSG.chomp
        module Math
          def self.sqrt(number); end
          def self.pi; end
        end
      MSG

      code2 = <<~MSG.chomp
        module Math
          def self.to_fixed_point; end
        end
      MSG

      # Execute
      uml_info = UMLInfoGenerator.process_multiple_code_snippets([code1, code2])

      # Assert
      expected_singleton_methods = <<~MSG.chomp
        self.sqrt(number)
        self.pi()
        self.to_fixed_point()
      MSG
      _(uml_info.module_singleton_methods).must_equal([expected_singleton_methods])
    end
  end

  describe 'when processing multiple code files' do
    it 'handles files correctly' do
      # Setup
      paths = ["test/test_uml_info_generator_with_multiple_files"]
      file_paths = PathTransformer.transform_files_and_or_directories_paths_to_file_paths(paths)

      # Execute
      uml_info = UMLInfoGenerator.process_files(file_paths)

      # Assert
      expected = [
        "EmptyLinkedList inherits LinkedList",
        "EmptyLinkedList includes Enumerable",
        "EmptyLinkedList prepends Extras",
        "EmptyLinkedList extends Abstract"
      ]
      _(uml_info.relationship_descriptions).must_equal(expected)    end
  end
end