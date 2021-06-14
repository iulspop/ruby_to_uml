require_relative '../lib/ruby_to_uml'

class TestClassProcessor < Minitest::Test
  def test_returns_list_of_every_class_in_file
    processor = ClassProcessor.new
    ast = Parser::CurrentRuby.parse_file('test/fixtures/monkey_kingdom.rb')

    classes = processor.process(ast)
    class_names = classes.map(&:name)
    assert_equal(%i[Monkey Doggy], class_names)
  end
end
