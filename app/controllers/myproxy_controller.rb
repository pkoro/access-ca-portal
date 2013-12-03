class MyproxyController < ApplicationController
  include X509Certificate
  include SortHelper
  include X509LoginHelper
  helper :sort
  before_filter :get_user_dn
  before_filter :check_accepted_certificate
	
  def index
	  @action_title = "Υπηρεσία MyProxy"
  end
  
  def create_myproxy
    @action_title = "Δημιουργία και καταχώρηση MyProxy πιστοποιητικού"
    @usercert = session[:usercert]
  end

  def myproxy_info
    @action_title = "Προβολή πληροφοριών MyProxy πιστοποιητικού"
    @usercert = session[:usercert]
  end
end
