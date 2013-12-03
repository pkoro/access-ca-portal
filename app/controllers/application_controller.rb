# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  include ExceptionNotifiable
  before_filter :set_locale

  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end
  # def local_request?
  #   false
  # end
  
  def rescue2_action(exception)
      render( :file => "#{RAILS_ROOT}/public/404.html",
              :status => "404 Not Found")
  end
  
  def render_comatose(context_hash)
    if context_hash[:page].nil?
      context_hash[:page] = "home"
    end
    if context_hash[:locals].nil?
      context_hash[:locals] = {}
    end
    if context_hash[:layout] != false
      context_hash[:layout] = true
    end
    cpage = ComatosePage.find_by_path(I18n.locale.to_s + "/web/" + context_hash[:page])
    if cpage then
      @page_title = cpage.title
      render :text => Comatose::ProcessingContext.new(cpage,context_hash[:locals]).page.content.gsub("&#8216;","'").gsub("&#8217;","'") , :layout=> context_hash[:layout]
    else
      cpage = ComatosePage.find_by_path(I18n.locale.to_s + "/error/404")
      if cpage then
        render :text => Comatose::ProcessingContext.new(cpage,context_hash[:locals]).page.content , :layout=> context_hash[:layout],  :status=>404
      else
        render :text => "This page wasn't found: "+ I18n.locale.to_s + "/web/" + context_hash[:page],  :status=>404
      end
   end
  end
end
