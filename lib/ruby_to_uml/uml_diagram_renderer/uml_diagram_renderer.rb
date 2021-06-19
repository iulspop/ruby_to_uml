require 'erb'
require 'tilt'

module UMLDiagramRenderer
  def self.create_diagram(dsl_string)
    html = render_diagram(dsl_string)
    save_html_file(html)
  end

  class << UMLDiagramRenderer
    private
    def render_diagram(dsl_string)
      template = Tilt.new('lib/ruby_to_uml/uml_diagram_renderer/uml_diagram_template.erb')
      template.render(Object.new, dsl_string: dsl_string)
    end
  
    def save_html_file(data)
      File.open("uml_class_diagram.html", 'w') do |file|
        file << data
      end
    end
  end
end