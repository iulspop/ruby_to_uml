module ParseToUMLInfo
  def self.process(files)
    top_level_node = parse_files_to_ast(files)
    parse_ast_to_uml_info(top_level_node)
  end

  def self.parse_files_to_ast(files)
    Parser::CurrentRuby.parse_file(files[0])
  end
  private_class_method :parse_files_to_ast

  def self.parse_ast_to_uml_info(top_level_node)
    processor = ASTProcessor.new
    processor.process(top_level_node)
    processor.classes
  end
  private_class_method :parse_ast_to_uml_info

  class ASTProcessor < Parser::AST::Processor
    attr_reader :classes

    def initialize
      @classes = []
    end

    def on_class(node)
      add_class(node)
      node.updated(nil, process_all(node))
    end

    private

    def add_class(node)
      constant, inherit, children = *node
      name = constant.children[1]
      @classes << name
    end
  end
end
