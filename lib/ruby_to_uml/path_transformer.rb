require 'pathname'

module PathTransformer
  def self.transform_files_and_or_directories_paths_to_file_paths(paths)
    paths.map { |path| resolve_absolute_path(path) }
         .map { |path| path.file? ? path : resolve_children(path) }
         .flatten
         .map(&:to_s)
         .filter { |path| path.match?(/.rb$/)}
         .sort
  end

  class << PathTransformer
    private
    def resolve_absolute_path(path)
      Pathname.new(File.expand_path(path, Dir.pwd))
    end

    def resolve_children(path)
      path.children.map do |child|
        if child.file?
          child
        elsif child.directory?
          resolve_children(child)
        end
      end
    end
  end
end