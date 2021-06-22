require_relative '../lib/ruby_to_uml'

describe "PathTransformer" do
  it "when given path to directory relative to the working directory, " \
     "it returns absolute path for every file in a directory and its nested directories" do
    # Execute
    paths = ["test/test_path_transformer/dummy_folder"]
    result = PathTransformer.transform_files_and_or_directories_paths_to_file_paths(paths)

    # Assert
    expected = [
      'test/test_path_transformer/dummy_folder/1.rb',
      'test/test_path_transformer/dummy_folder/nested_folder/2.rb'
    ].map { |file| File.expand_path(file, Dir.pwd)}
    _(result).must_equal(expected)
  end

  it "when given path to directory relative to the working directory using './' notation, " \
  "it returns absolute path for every file in a directory and its nested directories" do
 # Execute
 paths = ["./test/test_path_transformer/dummy_folder"]
 result = PathTransformer.transform_files_and_or_directories_paths_to_file_paths(paths)

 # Assert
 expected = [
   'test/test_path_transformer/dummy_folder/1.rb',
   'test/test_path_transformer/dummy_folder/nested_folder/2.rb'
 ].map { |file| File.expand_path(file, Dir.pwd)}
 _(result).must_equal(expected)
end

  it "when given paths to two directories and a file, " \
     "it returns absolute path of whole set of files" do
      # Execute
      paths = [
        "test/test_path_transformer/dummy_folder",
        "test/test_path_transformer/dummy_folder_2",
        "test/test_path_transformer/4.rb"
      ]
      result = PathTransformer.transform_files_and_or_directories_paths_to_file_paths(paths)

      # Assert
      expected = [
        'test/test_path_transformer/4.rb',
        'test/test_path_transformer/dummy_folder/1.rb',
        'test/test_path_transformer/dummy_folder/nested_folder/2.rb',
        'test/test_path_transformer/dummy_folder_2/3.rb'
      ].map { |file| File.expand_path(file, Dir.pwd)}
      _(result).must_equal(expected)
   end

  it "when directory contains files other than Ruby files, " \
     "it returns paths only to files that end in '.rb'" do
      # Execute
      paths = ["test/test_path_transformer/dummy_folder_3"]
      result = PathTransformer.transform_files_and_or_directories_paths_to_file_paths(paths)

      # Assert
      expected = [
        'test/test_path_transformer/dummy_folder_3/1.rb'
      ].map { |file| File.expand_path(file, Dir.pwd)}
      _(result).must_equal(expected)
  end
end