guard 'rspec', :version => 2, :bundler => true, :cli => '--colour --format nested --debugger' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec/" }
end

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end