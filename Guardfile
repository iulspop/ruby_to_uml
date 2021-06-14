directories %w(test lib)

guard :minitest do
  watch(%r{^test/(.*/)?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$}) { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^lib/ruby_to_uml\.rb$}) { 'test' }
  watch(%r{^test/fixtures\.*\.rb$}) { 'test' }
end