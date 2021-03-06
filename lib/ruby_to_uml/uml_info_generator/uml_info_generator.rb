require 'parser/current'

require 'ruby_to_uml/uml_info_generator/processor_helpers'
require 'ruby_to_uml/uml_info_generator/ast_processor'
require 'ruby_to_uml/uml_info_generator/info_classes'

module RubyToUML
  module UMLInfoGenerator
    def self.process_files(file_paths)
      uml_infos = file_paths.each_with_object([]) do |file_path, uml_infos|
        uml_infos << process_file(file_path)
      end

      uml_infos.reduce(:merge)
    end

    def self.process_multiple_code_snippets(code_snippets)
      uml_infos = code_snippets.each_with_object([]) do |code, uml_infos|
        uml_infos << process_code(code)
      end

      uml_infos.reduce(:merge)
    end

    def self.process_file(file_path)
      top_level_node = Parser::CurrentRuby.parse_file(file_path)
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
end