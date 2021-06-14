directories %w[test lib]

guard :minitest do
  watch(%r{^lib/(.*)$}) { 'test' }
  watch(%r{^test/(.*)$}) { 'test' }
end
