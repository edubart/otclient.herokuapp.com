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

  def instance_link(uid, text)
    "<a href=\"/instance/#{uid}\">#{text}</a>"
  end

  def otserv_link(uid, text)
    "<a href=\"/otserv/#{uid}\">#{text}</a>"
  end

  def minutes_to_units(seconds)
    '%d days, %d hours, %d minutes' %
      [24,60].reverse.inject([seconds]) {|result, unitsize|
        result[0,0] = result.shift.divmod(unitsize)
        result
      }
  end
end
