require_relative '../lib/ruby_to_uml'

describe UMLInfoGenerator do
  describe 'when processing multiple code files' do
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
end