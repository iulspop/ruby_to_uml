module ParseToUMLInfo
  def self.process(files)
    top_level_node = parse_file_to_ast(files[0])
    parse_ast_to_uml_info(top_level_node)
  end

  def self.parse_file_to_ast(file)
    Parser::CurrentRuby.parse_file(file)
  end
  private_class_method :parse_file_to_ast

  def self.parse_ast_to_uml_info(top_level_node)
    processor = ASTProcessor.new
    processor.process(top_level_node)
    UMLInfo.new(processor.classes)
  end
  private_class_method :parse_ast_to_uml_info

  class ASTProcessor < Parser::AST::Processor
    attr_reader :classes

    def initialize
      @classes = []
    end

    def on_class(node)
      name = get_class_name(node)
      add_class(name)
      node.updated(nil, process_all(node))
    end

    private

    def get_class_name(node)
      constant, inherit, children = *node
      # Unscoped Constant form: (const nil :ConstantName)
      # nil represents no scope, could be scoped to another constant
      constant.children[1]
    end

    def add_class(name)
      classes << ClassInfo.new(name.to_s)
    end
  end

  class ClassInfo
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class UMLInfo
    def initialize(classes, modules = [], relationships = [])
      @classes = classes
      @modules = modules
      @relationships = relationships
    end

    def class_names
      classes.map(&:name)
    end

    private

    attr_reader :classes
  end
end
