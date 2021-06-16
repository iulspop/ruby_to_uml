require_relative "ast_processor.rb"
require_relative "info_classes.rb"

module UMLInfoGenerator
  def self.process_file(file)
    top_level_node = Parser::CurrentRuby.parse_file(file)
    parse_ast_to_uml_info(top_level_node)
  end

  def self.process_code(code)
    top_level_node = Parser::CurrentRuby.parse(code)
    parse_ast_to_uml_info(top_level_node)
  end

  def self.parse_ast_to_uml_info(top_level_node)
    processor = ASTProcessor.new
    processor.process(top_level_node)
    UMLInfo.new(processor.classes, processor.modules, processor.relationships)
  end
  private_class_method :parse_ast_to_uml_info
end
