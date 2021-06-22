module RubyToUML
  module CLI
    def self.start(arguments)
      abort('Usage: ruby_to_uml [source directory or file]') if arguments.empty?
      file_paths = PathTransformer.transform_files_and_or_directories_paths_to_file_paths(arguments)
      uml_info = UMLInfoGenerator.process_files(file_paths)
      dsl = NomnomlDSLGenerator.generate_dsl(uml_info)
      UMLDiagramRenderer.create_diagram(dsl.to_s)
    end
  end
end