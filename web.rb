require 'sinatra'
require 'haml'
require 'sass'
require 'mongoid'

configure do
    Mongoid.load!('mongoid.yml')
end

class Report
  include Mongoid::Document

  belongs_to :user

  field :ip, type: String
  field :date, type: Time
  field :os, type: String
  field :graphics_vendor, type: String
  field :graphics_renderer, type: String
  field :graphics_version, type: String
  field :painter_engine, type: Integer
  field :fps, type: Integer
  field :max_fps, type: Integer
  field :fullscreen, type: Boolean
  field :window_width, type: Integer
  field :window_height, type: Integer
  field :player_name, type: String
  field :otserv_host, type: String
  field :otserv_port, type: Integer
  field :otserv_protocol, type: Integer
  field :build_version, type: String
  field :build_revision, type: Integer
  field :build_commit, type: String
  field :build_date, type: Time
  field :display_width, type: Integer
  field :display_height, type: Integer
end

class User
  include Mongoid::Document
  has_many :reports
  field :uid, type: String
end

get '/main.css' do
  sass :main
end

post '/report' do
  report = Report.create(params)
  report.date = Time.now
  report.ip = request.ip
  report.save()
end

get '/' do
  @reports = Report.all
  haml :index
end
