require 'simplecov'
SimpleCov.start

require 'rspec'
require 'pronto/flake8'

Dir.glob(Dir.pwd + '/spec/support/**/*.rb') { |file| require file }

# Cross-platform way of finding an executable in the $PATH.
#
#   which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end


puts 'Specccc Helper'
if which('flake8').nil?
  raise 'Please `pip install flake8` or ensure flake8 is in your PATH'
end
RSpec.configure do |c|
  c.include RepositoryHelper
end
