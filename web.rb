require 'sinatra'
require 'haml'
require './configs'
require './helpers'
require './models'

# Index
get '/' do
  if logged_in? then
    redirect '/dashboard'
  else
    redirect '/login'
  end
end

# Reporting
post '/report' do
  report = Report.create(params)
  report.date = Time.now
  report.ip = request.ip
  report.save()

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

    instance.last_player = player
    instance.save
  end
end

# Authentication
get '/login' do
  if logged_in?
    redirect '/dashboard'
  else
    haml :login, :layout => false
  end
end

post '/login' do
  admin = Admin.where(:username => params['username'], :password => params['password']).first
  if admin then
    session[:admin] = admin
    redirect '/'
  else
    flash("Username or password incorrect")
    redirect '/login'
  end
end

get '/logout' do
  session[:admin] = nil
  redirect '/'
end

# Admin only
get '/dashboard' do
  redirect '/instances'
  #login_required
  #haml :dashboard
end

get '/reports' do
  login_required
  @reports = Report.desc(:date)
  haml :reports
end

get '/instances' do
  login_required
  @instances = Instance.desc(:updated_on)
  haml :instances
end

get '/players' do
  login_required
  @players = Player.all.desc(:updated_on)
  haml :players
end

get '/otservs' do
  login_required
  @otservs = Otserv.all.desc(:updated_on)
  haml :otservs
end
