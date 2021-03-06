require 'ruby_to_uml'

describe 'RubyToUML::UMLDiagramRenderer' do
  it 'renders and saves an html file from a template' do
    # Setup
    file_name = 'uml_class_diagram.html'

    # Execute
    dsl_string = '[]'
    RubyToUML::UMLDiagramRenderer.create_diagram(dsl_string)

    # Assert
    _(File.exist?(file_name)).must_equal(true)

    # Teardown
    File.delete(file_name) if File.exist?(file_name)
  end
end
