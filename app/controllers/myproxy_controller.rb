class MyproxyController < ApplicationController
  include X509Certificate
  include SortHelper
  include X509LoginHelper
  helper :sort
  before_filter :get_user_dn
  before_filter :check_accepted_certificate
	
  
  def index
	  @action_title = "#{I18n.t "controllers.myproxy.myproxy_service"}"
  end
  
  def create_myproxy
    @action_title = "#{I18n.t "controllers.myproxy.create_register_myproxy_cert"}"
    @usercert = session[:usercert]
  end

  def myproxy_info
    @action_title = "#{I18n.t "controllers.myproxy.view_myproxy_cert"}"
    @usercert = session[:usercert]
  end
end
