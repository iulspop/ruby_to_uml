require 'erb'
require 'tilt'

module RubyToUML
  module UMLDiagramRenderer
    def self.create_diagram(dsl_string)
      html = render_diagram(dsl_string)
      save_html_file(html)
    end

    class << UMLDiagramRenderer
      private

      def render_diagram(dsl_string)
        absolute_path = File.expand_path('uml_diagram_template.erb', __dir__)
        template = Tilt.new(absolute_path)
        template.render(Object.new, dsl_string: dsl_string)
      end

      def save_html_file(data)
        File.open('uml_class_diagram.html', 'w') do |file|
          file << data
        end
      end
    end
  end
end