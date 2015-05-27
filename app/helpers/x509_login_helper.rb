module X509LoginHelper
  def get_user_dn
    if local_request?
      session[:usercert] = "/C=GR/O=HellasGrid/OU=auth.gr/CN=Stefanos Laskaridis"
    end		
    if request.env['HTTP_REDIRECT_SSL_CLIENT_S_DN'] =~ /CN/
        session[:usercert] = request.env['HTTP_REDIRECT_SSL_CLIENT_S_DN']
    end
    if (request.env['REDIRECT_SSL_CLIENT_S_DN'] =~ /CN/)
      session[:usercert] = request.env['REDIRECT_SSL_CLIENT_S_DN']
    end
    if ! session[:usercert] && params[:controller] != "cert" && params[:action] != "test_browser_for_user_cert"
      redirect_to :controller => "cert", :action => "test_browser_for_user_cert", :trailing_slash => true
    end
    return
  end

  def check_accepted_certificate
    if session[:usercert] && ! session[:userid]
      crt = Certificate.find_by_subject_dn(session[:usercert], :order => "created_at DESC")
      if crt
        if crt.status != "valid"
          redirect_to :controller => "account", :action => "accept_personal_certificate", :id => crt.certificate_request_uniqueid, :redirected_from_controller => params[:controller], :redirected_from_action => params[:action]
        else
          session[:userid] = crt.owner_id
        end
      else
        redirect_to :controller => "register", :action => "index"
      end
    end
  end
  
  def login_required(role=nil)
    get_user_dn
    
	  if session[:usercert]
	    case session[:usercert]
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Christos Kanellopoulos"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Christos Triantafyllidis"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Nikolaos Triantafyllidis"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Paschalis Korosoglou"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Stefanos Laskaridis"
        has_access=true
      else
        has_access=false
      end
    else
	    has_access=false
    end
    
    if not has_access
      redirect_to :controller => "register", :action => "index"
    end
  end
end