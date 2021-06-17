require 'parser/current'
require_relative "processor_helpers"
require_relative "ast_processor.rb"
require_relative "info_classes.rb"

module UMLInfoGenerator
  def self.process_multiple_code_snippets(code_snippets)
    uml_infos = code_snippets.each_with_object([]) do |code, uml_infos|
      uml_infos << process_code(code)
    end

    uml_infos.reduce { |accumulator, uml_info| uml_info.merge(accumulator) }
  end

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
