require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/all.rb' 
  t.libs << 'test'          
  t.warning = false         
end

desc "Build all syntax files"
task :build_syntaxes do
  # You could add conversion tasks between formats here
  puts "Syntax files are ready in syntaxes/"
end

desc "Run tests"
task default: :test