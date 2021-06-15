require_relative '../lib/ruby_to_uml'

class TestParseToUMLInfo < Minitest::Test
  def test_returns_list_of_every_class_name_in_file
    files = %w[test/fixtures/linked_list.rb]

    uml_info = ParseToUMLInfo.process(files)

    assert_equal(%i[LinkedList EmptyLinkedList], uml_info.class_names)
  end
end
