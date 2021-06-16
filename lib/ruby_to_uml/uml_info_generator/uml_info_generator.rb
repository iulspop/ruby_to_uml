require_relative "ast_processor.rb"
require_relative "info_classes.rb"

module UMLInfoGenerator
  def self.process(files)
    top_level_node = Parser::CurrentRuby.parse_file(files[0])
    parse_ast_to_uml_info(top_level_node)
  end

  def self.code(code)
    top_level_node = Parser::CurrentRuby.parse(code)
    parse_ast_to_uml_info(top_level_node)
  end

  def self.parse_ast_to_uml_info(top_level_node)
    processor = ASTProcessor.new
    processor.process(top_level_node)
    UMLInfo.new(processor.classes, [], processor.relationships)
  end
  private_class_method :parse_ast_to_uml_info
end
