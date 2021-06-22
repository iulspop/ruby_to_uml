$LOAD_PATH << File.expand_path('lib', __dir__)

Gem::Specification.new do |spec|
  spec.name     = 'ruby_to_uml'
  spec.version  = '1.0.0'

  spec.summary  = 'ruby_to_uml is a tool that creates UML class diagrams from Ruby code.'
  spec.homepage = 'https://github.com/iulspop/ruby_to_uml'
  spec.metadata = { "source_code_uri" => "https://github.com/iulspop/ruby_to_uml" }
  spec.license  = 'MIT'

  spec.authors  = ['Iuliu Pop']
  spec.email    = ['iuliu.laurentiu.pop@protonmail.com']

  spec.required_ruby_version = '>= 3.0.1'

  spec.add_runtime_dependency('erb')
  spec.add_runtime_dependency('parser')
  spec.add_runtime_dependency('tilt')

  spec.executables << 'ruby_to_uml'

  spec.files = [
    "bin/ruby_to_uml",
    "lib/ruby_to_uml.rb",
    "lib/ruby_to_uml/cli.rb",
    "lib/ruby_to_uml/nomnoml_dsl_generator.rb",
    "lib/ruby_to_uml/path_transformer.rb",
    "lib/ruby_to_uml/uml_diagram_renderer/uml_diagram_renderer.rb",
    "lib/ruby_to_uml/uml_diagram_renderer/uml_diagram_template.erb",
    "lib/ruby_to_uml/uml_info_generator/ast_processor.rb",
    "lib/ruby_to_uml/uml_info_generator/info_classes.rb",
    "lib/ruby_to_uml/uml_info_generator/processor_helpers.rb",
    "lib/ruby_to_uml/uml_info_generator/uml_info_generator.rb"
  ]
end
