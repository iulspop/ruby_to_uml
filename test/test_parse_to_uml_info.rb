require_relative '../lib/ruby_to_uml'

class TestParseToUMLInfo < Minitest::Test
  def setup
    files = %w[test/fixtures/linked_list.rb]
    @uml_info = ParseToUMLInfo.process(files)
  end

  def test_classes_returns_name_of_every_class_in_files
    classes = %w[LinkedList EmptyLinkedList]
    assert_equal(classes, @uml_info.classes)
  end

  def test_relationships_returns_inheritence_relationships
    relationships = ["EmptyLinkedList inherits LinkedList"]
    assert_equal(relationships, @uml_info.relationships)
  end
end
