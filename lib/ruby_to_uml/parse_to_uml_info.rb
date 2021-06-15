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
    UMLInfo.new(processor.classes, [], processor.relationships)
  end
  private_class_method :parse_ast_to_uml_info

  class ASTProcessor < Parser::AST::Processor
    attr_reader :classes, :relationships

    def initialize
      @classes = []
      @relationships = []
    end

    def on_class(node)
      name = get_class_name(node)
      add_inheritence_relationship_if_exists(name, node)

      add_class(name)

      node.updated(nil, process_all(node))
    end

    private

    def get_class_name(node)
      constant, inherit, children = *node
      # Unscoped Constant form: (const nil :ConstantName)
      # nil represents no scope, could be scoped to another constant
      get_constant_name(constant)
    end

    def get_constant_name(constant)
      constant.children[1]
    end

    def add_inheritence_relationship_if_exists(name, node)
      superclass = get_superclass_name(node)
      if superclass
        relationships << RelationshipInfo.new(name, superclass, :inherits)
      end
    end

    def get_superclass_name(node)
      constant, inherit, children = *node
      inherit ? get_constant_name(inherit) : nil
    end

    def add_class(name)
      classes << ClassInfo.new(name.to_s)
    end
  end

  ClassInfo = Struct.new(:name)

  RelationshipInfo = Struct.new(:subject, :object, :verb) do
    def to_s
      "#{subject} #{verb} #{object}"
    end
  end

  class UMLInfo
    def initialize(classes, modules = [], relationships = [])
      @classes = classes
      @modules = modules
      @relationships = relationships
    end

    def classes
      @classes.map(&:name)
    end

    def relationships
      @relationships.map(&:to_s)
    end
  end
end
