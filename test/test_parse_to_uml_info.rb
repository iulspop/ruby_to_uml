require_relative '../lib/ruby_to_uml'

class TestParseToUMLInfo < Minitest::Test
  def setup
    files = %w[test/fixtures/linked_list.rb]
    @uml_info = ParseToUMLInfo.process(files)
  end

  def test_returns_list_of_every_class_name_in_file
    classes = %w[LinkedList EmptyLinkedList]
    assert_equal(classes, @uml_info.class_names)
  end
end
