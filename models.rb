class Admin
  include Mongoid::Document
  field :username, type: String
  field :password, type: String
end

class Report
  include Mongoid::Document

  field :player_name, type: String
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
  field :fps_history, type: Array
  field :max_fps, type: Integer
  field :fullscreen, type: Boolean
  field :window_width, type: Integer
  field :window_height, type: Integer
  field :world_name, type: String
  field :world_host, type: String
  field :world_port, type: String
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
  include Mongoid::Document

  has_many :worlds
  has_many :players

  field :created_on, type: Time, default: -> { Time.now }
  field :updated_on, type: Time, default: -> { Time.now }
  field :hosts, type: Array
  field :port, type: Integer
  field :name, type: String
  field :protocol, type: Integer

  index({ hosts: 1 })

  def host
    return hosts.first
  end

  def self.get(host)
    otserv = self.where(:hosts.in => [ host ]).first
    if not otserv
      otserv = self.create(:hosts => [host], :name => host)
      otserv.save
    end
    return otserv
  end

  def process_report(report)
    if self[:port] != report.otserv_port or
       self[:protocol] != report.otserv_protocol then
      self[:port] = report.otserv_port
      self[:protocol] = report.otserv_protocol
      self[:updated_on] = Time.now
    end
  end

  def minutes_played
    sum = 0
    players.each do |player|
      sum += player.minutes_played
    end
    sum
  end

  def num_players
    return players.count
  end
end

class World
  include Mongoid::Document

  belongs_to :otserv
  has_many :players

  field :created_on, type: Time, default: -> { Time.now }
  field :updated_on, type: Time, default: -> { Time.now }
  field :name, type: String
  field :host, type: String
  field :port, type: Integer

  index({ otserv_id: 1, name: 1 }, { unique: true })

  def self.get(otserv, name)
    world = self.where(otserv: otserv, name: name).first
    if not world then
      world = self.create(:otserv => otserv, :name => name)
    end
    return world
  end

  def process_report(report)
    if self[:name] != report.world_name or
       self[:host] != report.world_host or
       self[:port] != report.world_port then
      self[:name] = report.world_name
      self[:port] = report.world_port
      self[:host] = report.world_host
      self[:updated_on] = Time.now
    end
  end
end

class Player
  include Mongoid::Document

  belongs_to :world
  belongs_to :otserv
  belongs_to :instance
  field :created_on, type: Time, default: -> { Time.now }
  field :updated_on, type: Time, default: -> { Time.now }
  field :updates_count, type: Integer, default: -> { 0 }
  field :name, type: String

  index({ otserv_id: 1, name: 1 }, { unique: true })

  def self.get(otserv, name)
    player = self.where(otserv: otserv, name: name).first
    if not player
      player = self.create(:otserv => otserv, :name => name)
    end
    return player
  end

  def process_report(report)
    self[:updated_on] = Time.now
    self[:updates_count] = self[:updates_count].next
  end

  def minutes_played
    return self.updates_count
  end

  def online
    return self.updated_on >= Time.now - 90
  end
end

class Instance
  include Mongoid::Document

  has_many :players

  field :created_on, type: Time, default: -> { Time.now }
  field :updated_on, type: Time, default: -> { Time.now }
  field :updates_count, type: Integer, default: -> { 0 }
  field :uid, type: String
  field :os, type: String
  field :ip, type: String
  field :fps_history, type: Array, default: -> { [] }
  field :max_fps, type: Integer
  field :graphics_vendor, type: String
  field :graphics_renderer, type: String
  field :graphics_version, type: String
  field :painter_engine, type: Integer
  field :fullscreen, type: Boolean
  field :display_width, type: Integer
  field :display_height, type: Integer
  field :window_width, type: Integer
  field :window_height, type: Integer
  field :build_revision, type: Integer
  field :build_commit, type: String
  field :build_version, type: String
  field :build_date, type: String
  field :last_player_id, type: Moped::BSON::ObjectId

  index({ uid: 1 }, { unique: true })

  def average_fps
    sum = 0
    fps_history.each do |fps|
      sum += fps
    end
    return sum/fps_history.count
  end

  def min_fps
    fps_history.min
  end

  def max_fps
    fps_history.max
  end

  def fps
    fps_history.last
  end

  def self.get(uid)
    instance = self.where(uid: uid).first
    if not instance then
      instance = self.create(:uid => uid, :updates_count => 0)
      instance.save!
    end
    return instance
  end

  def process_report(report)
    fpsh = Array.new(self[:fps_history].last(59))
    fpsh << report.fps

    self[:updated_on] = Time.now
    self[:updates_count] = self[:updates_count].next
    self[:fps_history] = fpsh
    self[:os] = report.os
    self[:ip] = report.ip
    self[:max_fps] = report.max_fps
    self[:graphics_vendor] = report.graphics_vendor
    self[:graphics_renderer] = report.graphics_renderer
    self[:graphics_version] = report.graphics_version
    self[:painter_engine] = report.painter_engine
    self[:fullscreen] = report.fullscreen
    self[:window_width] = report.window_width
    self[:window_height] = report.window_height
    self[:display_width] = report.display_width
    self[:display_height] = report.display_height
    self[:build_revision] = report.build_revision
    self[:build_commit] = report.build_commit
    self[:build_date] = report.build_date
    self[:build_version] = report.build_version
  end

  def compact_graphics_renderer
    graphics = self[:graphics_renderer]
    graphics = graphics.gsub("Microsoft Corporation ", "")
    graphics = graphics.gsub("Express Chipset Family", "")
    graphics
  end

  def last_player=(player)
    self[:last_player_id] = player.id
  end

  def last_player
    @last_player ||= Player.where(id: self[:last_player_id]).first
  end

  def online
    return self.updated_on >= Time.now - 90
  end

  def otservs
    players.collect { |player| player.otserv }
  end

  def minutes_played
    sum = 0
    players.each do |player|
      sum += player.minutes_played
    end
    sum
  end

  def self.total_minutes_played
    sum = 0
    Instance.all.each do |instance|
      sum += instance.minutes_played
    end
    sum
  end
end
