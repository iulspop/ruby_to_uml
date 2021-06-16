require_relative '../lib/ruby_to_uml'

class TestUMLInfoGenerator < Minitest::Test
  def setup
    files = %w[test/fixtures/linked_list.rb]
    @uml_info = UMLInfoGenerator.process(files)
  end

  def test_classes_returns_name_of_every_class_in_files
    classes = %w[Stack LinkedList EmptyLinkedList]
    assert_equal(classes, @uml_info.class_names)
  end

  def test_classes_contain_instance_methods
    stack = ""
    linked_list = <<~MSG.chomp
      public conj(item)
      public empty?()
      public ==(other)
      protected initialize(head, tail, dragon, wisdom)
      private traverse(index)
    MSG
    empty_linked_list = <<~MSG.chomp
      public initialize()
      public empty?()
    MSG
    expected_methods = [stack, linked_list, empty_linked_list]
    actual_methods = @uml_info.classes.map { |class_info| class_info.instance_methods_info.map(&:to_s).join("\n") }
    assert_equal(expected_methods, actual_methods)
  end

  def test_classes_contain_singleton_methods
    stack = ""
    linked_list = <<~MSG.chomp
      self.make(args)
      self.cons(head, tail)
      self.empty()
    MSG
    empty_linked_list = <<~MSG.chomp
      self.cons(head, tail)
    MSG
    expected_methods = [stack, linked_list, empty_linked_list]
    actual_methods = @uml_info.classes.map { |class_info| class_info.singleton_methods_info.map(&:to_s).join("\n") }
    assert_equal(expected_methods, actual_methods)
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

class TestUMLInfoGeneratorNew < Minitest::Test
  def test_classes_contain_instance_methods_even_when_only_one_method_defined
    code = <<~MSG.chomp
      class Turtle
        def yellow(iron)

        end
      end
    MSG

    turtle = <<~MSG.chomp
      public yellow(iron)
    MSG

    @uml_info = UMLInfoGenerator.code(code)
    expected_methods = [turtle]
    actual_methods = @uml_info.classes.map { |class_info| class_info.instance_methods_info.map(&:to_s).join("\n") }
    assert_equal(expected_methods, actual_methods)
  end
end