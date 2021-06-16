module UMLInfoGenerator
  class ASTProcessor < Parser::AST::Processor
    include ProcessorHelpers
    include ClassAndRelationshipsProcessor
    include ModuleProcesor
    attr_reader :classes, :modules, :relationships

    def initialize
      @classes = []
      @modules = []
      @relationships = []
    end
  end
end
