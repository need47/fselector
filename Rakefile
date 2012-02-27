#
# make a ruby gem
#

task :default => :gem

task :gem do
  Gem::Builder.new(eval(File.read('fselector.gemspec'))).build
end

#
# test example
#
require 'rake'
require 'rake/testtask.rb'
task :test do
  Rake::TestTask.new do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/test_*.rb']
    t.verbose = true
  end
end