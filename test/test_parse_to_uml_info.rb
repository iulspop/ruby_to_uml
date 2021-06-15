require_relative '../lib/ruby_to_uml'

class TestUMLInfoGenerator < Minitest::Test
  def setup
    files = %w[test/fixtures/linked_list.rb]
    @uml_info = UMLInfoGenerator.process(files)
  end

  def test_classes_returns_name_of_every_class_in_files
    classes = %w[Stack LinkedList EmptyLinkedList]
    assert_equal(classes, @uml_info.classes)
  end

  def test_relationships_includes_any_inheritence_relationships
    inherits_relationship = "EmptyLinkedList inherits LinkedList"
    assert_includes(@uml_info.relationships, inherits_relationship)
  end

  def test_relationships_includes_any_include_relationships
    includes_relationship = "LinkedList includes Enumerable"
    assert_includes(@uml_info.relationships, includes_relationship)
  end

  def test_relationships_includes_any_extend_relationships
    extends_relationship = "LinkedList extends Utils"
    assert_includes(@uml_info.relationships, extends_relationship)
  end

  def test_relationships_includes_any_prepend_relationships
    prepends_relationship = "Stack prepends Extras"
    assert_includes(@uml_info.relationships, prepends_relationship)
  end
end
