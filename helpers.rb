helpers do
  def logged_in?
    return !!session[:admin]
  end

  def current_admin
    return session[:admin]
  end

  def login_required
    if current_admin
      return true
    else
      session[:return_to] = request.fullpath
      redirect '/login'
      return false
    end
  end

  def link_to(url,text=url,opts={})
    attributes = ""
    opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end

  def nav_link(url,text=url,opts={})
    attributes = ""
    opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
    if request.path == url
      liattrs = 'class="active"'
    end
    "<li #{liattrs}><a href=\"#{url}\" #{attributes}>#{text}</a></li>"
  end

  def instance_link(uid, text=uid)
    text = h(text)
    "<a href=\"/instance/#{uid}\">#{text}</a>"
  end

  def otserv_link(uid, text=uid)
    text = h(text)
    "<a href=\"/otserv/#{uid}\">#{text}</a>"
  end

  def minutes_to_units(seconds)
    '%d days, %d hours, %d minutes' %
      [24,60].reverse.inject([seconds]) {|result, unitsize|
        result[0,0] = result.shift.divmod(unitsize)
        result
      }
  end

  def h(what)
    Rack::Utils.escape_html(what.to_s.force_encoding("cp1252").encode("utf-8"))
  end

  def get_players_graph_data
    data = "["
    30.downto(1) do |i|
      data << "#{Player.where(:created_on.lt => Time.now - (i*24*3600)).count.to_s},"
    end
    data << "#{Player.all.count.to_s}]"
    data
  end

  def get_otservs_graph_data
    data = "["
    30.downto(1) do |i|
      data << "#{Otserv.where(:created_on.lt => Time.now - (i*24*3600)).count.to_s},"
    end
    data << "#{Otserv.all.count.to_s}]"
    data
  end

  def get_instances_graph_data
    data = "["
    30.downto(1) do |i|
      num = Instance.where(:created_on.lt => Time.now - (i*24*3600)).count
      data << "#{Instance.where(:created_on.lt => Time.now - (i*24*3600)).count.to_s},"
    end
    data << "#{Instance.all.count.to_s}]"
    data
  end

  def get_fps_graph_data
    fpses = Array.new
    Instance.all.each do |player|
      fpses += player.fps_history
    end
    data = "["
    1.upto(1000) do |i|
      percent = ((fpses.count { |fps| fps <= i }).to_f * 100.0)/fpses.count
      data << "#{percent},"
    end
    data = data.chomp(",")
    data << "]"
    data
  end
end
