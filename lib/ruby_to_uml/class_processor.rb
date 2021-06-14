class ClassProcessor < Parser::AST::Processor
  attr_reader :classes

  def initialize
    @classes = []
  end

  def on_class(node)
    constant, inherit, children = *node
    name = constant.children[1]
    classes << ClassInfo.new(name)
    classes
  end

  def on_begin(node)
    process_all(node)
    classes
  end
end

class ClassInfo
  attr_reader :name

  def initialize(name)
    @name = name
  end
end
