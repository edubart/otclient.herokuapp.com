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

  def flash(msg)
    session[:flash] = msg
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
end
