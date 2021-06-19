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
      
    end

    it 'merges the attributes and methods of duplicate classes into a single class' do
      
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