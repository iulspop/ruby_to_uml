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

    it 'returns only unique modules' do
      
    end

    it 'merges the methods of duplicate modules into a single module' do
      
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