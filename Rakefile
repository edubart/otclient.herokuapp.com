require 'mongoid'
require './models'
Mongoid.load!('mongoid.yml')

task :import_reports do
  Otserv.all.destroy
  World.all.destroy
  Player.all.destroy
  Instance.all.destroy
  Report.all.each do |report|
    otserv = nil
    world = nil
    instance = nil
    player = nil

    if report.uid then
      instance = Instance.get(report.uid)
      instance.process_report(report)
      instance.save
    else
      next
    end

    if report.otserv_host then
      otserv = Otserv.get(report.otserv_host)
      otserv.process_report(report)
      otserv.save
    end

    if otserv and report.world_name then
      world = World.get(otserv, report.world_name)
      world.process_report(report)
      world.save
    end

    if otserv and report.player_name then
      player = Player.get(otserv, report.player_name)
      player.process_report(report)
      player.world = world
      player.instance = instance
      player.save

      instance.last_player_id = player.id
      instance.save
    end
  end
end

namespace :db do
  task :create_indexes do
    Otserv.create_indexes
    World.create_indexes
    Player.create_indexes
    Instance.create_indexes
  end
end

