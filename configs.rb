require 'mongoid'

enable :sessions

configure do
  Mongoid.load!('mongoid.yml')
  enable :logging, :dump_errors, :raise_errors
end
