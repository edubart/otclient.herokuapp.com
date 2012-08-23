class Admin
  include Mongoid::Document
  field :username, type: String
  field :password, type: String
end

class Report
  include Mongoid::Document

  field :uid, type: String
  field :report_delay, type: Integer
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

class Otserv
  attr_accessor :host, :num_players, :minutes_played
end

class Player
  attr_accessor :name, :otserv_host, :minutes_played, :online
end
