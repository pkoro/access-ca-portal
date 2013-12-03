class SupportController < ApplicationController
  include SortHelper
  helper :sort
  include X509LoginHelper
  before_filter :get_user_dn, :except => [:gridmapfile]
  before_filter :redirect_non_ssl_authenticated, :except => [:gridmapfile]
  before_filter :check_accepted_certificate, :except => [:has_support_access,:gridmapfile]
  before_filter :has_support_access, :except => [:gridmapfile]
  
  def gridmapfile
    result_array =[]
    max_person_id = Person.find(:all).size
    Person.find(:all, :order => "id ASC").each do |person|
      if person.personal_certificate
        result_array << "\"" + person.personal_certificate.subject_dn + "\" hgaccess" + ("%04d" % person.id)
      end
    end
    render :text => result_array.join("\n")
  end

  def index
    redirect_to :action => "list_people"
  end

  def list_people
    @action_title = "Λίστα εγγεγραμμένων χρηστών"
    sort_init 'last_name_el'
    sort_update
    @people = Person.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :include => [:organization]
  end

  def show_person_details
    @action_title = "Πληροφορίες χρήστη"
    @person = Person.find(params[:id])
  end
  
  def list_certificate_requests
    @action_title = "Λίστα αιτήσεων για ψηφιακά πιστοποιητικά"
    sort_init 'created_at'
    sort_update
    @certificate_requests = CertificateRequest.paginate :page=>params[:page], :per_page => 20, :order => sort_clause
  end
  
  def list_see_vo_requests
    @action_title = "Λίστα αιτήσεων για το SEE VO"
    @see_vo_requests = SeeVoRequest.paginate :page=>params[:page], :per_page => 20, :order => "created_at DESC"
  end
  
  def list_ui_requests
    @action_title = "Λίστα αιτήσεων για πρόσβαση σε ΗellasGrid UI"
    @ui_requests = UiRequest.paginate :page=>params[:page], :per_page => 20, :order => "created_at DESC"
  end
  
  def export_registered_users
    headers['Content-Type'] = "application/vnd.ms-excel" 
    headers['Content-Disposition'] = 'attachment; filename="excel-export.xls"'
    headers['Cache-Control'] = ''
    @people = Person.find(:all)
    render (:layout=>false)
  end
  
  def logout
    reset_session
  end

private  
  def redirect_non_ssl_authenticated
	  if ! session[:usercert]
	    redirect_to :controller => "register", :action => "index"
    end
  end

  def has_support_access
    has_access=false
    if session[:userid] and Person.find(session[:userid]) and Person.find(session[:userid]).personal_certificate
      case Person.find(session[:userid]).personal_certificate.subject_dn
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Christos Kanellopoulos"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Christos Triantafyllidis"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Paschalis Korosoglou"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Dimitrios Folias"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Pavlos Daoglou"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=grnet.gr/CN=Kostas Koumantaros"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=grnet.gr/CN=Ioannis Liabotis"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=uoa.gr/CN=Vangelis Floros"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=cti.gr/CN=Vasilis Gkamas"
        has_access=true
      when "/C=GR/O=HellasGrid/OU=upatras.gr/CN=Kalliopi Giannakopoulou"
        has_access=true
      else
        has_access=false
      end
    else
      has_access=false
    end
    if !has_access
      redirect_to :controller => "register", :action => "index"
    end
  end
end
