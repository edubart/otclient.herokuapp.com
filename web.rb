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
  redirect '/reports'
  #login_required
  #haml :dashboard
end

get '/reports' do
  login_required
  @reports = Report.desc(:date).limit(100)
  haml :reports
end

get '/online' do
  login_required
  @reports = Report.desc(:date).where(:date.gte => Time.now - 300)
  haml :online
end

get '/players' do
  login_required
  player_names = Report.all.distinct(:player_name)
  @players = Array.new
  player_names.each do |name|
    player_reports = Report.where(player_name: name)
    player = Player.new
    player.name = name
    player.otserv_host = player_reports.last.otserv_host
    player.online = player_reports.last.date >= Time.now - 300
    player.minutes_played = player_reports.count
    @players << player
  end
  haml :players
end

get '/otservs' do
  login_required

  otserv_hosts = Report.all.distinct(:otserv_host)
  @otservs = Array.new
  otserv_hosts.each do |host|
    otserv_reports = Report.where(otserv_host: host).distinct(:player_name)
    otserv = Otserv.new
    otserv.host = host
    otserv.num_players = otserv_reports.count
    otserv.minutes_played = Report.where(otserv_host: host).count
    @otservs << otserv
  end

  haml :otservs
end
