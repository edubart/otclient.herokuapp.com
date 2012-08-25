require 'mongoid'
require 'sinatra'
require 'haml'
require 'rack-flash'

enable :sessions

configure do
  Mongoid.load!('mongoid.yml')
  enable :logging, :dump_errors, :raise_errors
  set :default_encoding, "utf-8"
end

use Rack::Flash
