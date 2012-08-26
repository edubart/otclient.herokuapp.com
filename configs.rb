require 'mongoid'
require 'sinatra'
require 'haml'
require 'rack-flash'

enable :sessions
use Rack::Flash

configure do
  Mongoid.load!('mongoid.yml')
  enable :logging, :dump_errors, :raise_errors
  set :default_encoding, "utf-8"
end
