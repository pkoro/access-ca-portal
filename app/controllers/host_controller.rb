class HostController < ApplicationController
  include X509Certificate
  include X509LoginHelper
  include SortHelper
  helper :sort
  before_filter :get_user_dn
  before_filter :check_accepted_certificate  

  def index
    redirect_to(:action=>"list")
  end

  def list
    @action_title = "#{I18n.t "controllers.host.host_list"}"
    admin = Person.find_by_dn(session[:usercert])
    sort_init 'fqdn'
    sort_update
    @hosts = Host.paginate :page => params[:page], :conditions => ["admin_id = ?", admin.id], :per_page => 20, :order => sort_clause, :include => [:organization]
  end

  def pending_requests
    @action_title = "#{I18n.t "controllers.host.pending_req_list"}"
    admin = Person.find_by_dn(session[:usercert])
    @requests = CertificateRequest.paginate :page => params[:page], :conditions => ["owner_type='Host' and requestor_id=? and (status='pending' or status='approved')" , admin.id], :per_page => 20
  end
  
  def show_host_details
    @action_title = "#{I18n.t "controllers.host.host_details"}"
    @host = Host.find(params[:id])
  end
  

  def manual_csr
    @action_title = "#{I18n.t "controllers.host.insert_cert_req"}"
    @admin = Person.find_by_dn(session[:usercert])
    if ! @admin
      flash[:notice] = "#{I18n.t "controllers.common.registration_first_notice"}"  
      redirect_to :controller => "register", :action => "registration_form"
    end
  end

  def tbd
  end
  
  def export_excel
    redirect_to :action => "tbd"
  end

  def csr_receipt
    if not params[:id]
      redirect_to :action => "manual_csr"
    else
      @action_title = "#{I18n.t "controllers.host.cert_req_details"}"
      @admin = Person.find_by_dn(session[:usercert])
      @cert_request = CertificateRequest.find_by_uniqueid(params[:id])
      @csr_status_link = url_for(:controller => "cert", :action => "monitor_request", :id => @cert_request.uniqueid)
      @csr_ra_link = url_for(:controller => "ra", :action => "show_request_details", :id => @cert_request.id)
      @ra_info = ""
      @cert_request.organization.registration_authorities.find(:all,:conditions=>["ra_id != 1"]).each {|o|
        @ra_info += o.description + ", " 
      }
      if @ra_info == ""
        @ra_info = RegistrationAuthority.find(1).description
      else
        @ra_info = @ra_info.chop.chop
      end
      RegistrationMailer.deliver_notification_of_csr_submition_to_ra(@admin, @cert_request, @csr_ra_link)
      RegistrationMailer.deliver_notification_of_host_csr_submition_to_user(@admin, @cert_request, @csr_status_link)
    end
  end

  # Pairnei ta dedomena apo etoimo CSR. To uniqueid
  # einai to SHA1 to xronou se sec.microsecond
  # Epixhs dhmiourgia kai apo8hkeysh sto CSR stelnei
  # sto csr_receipt, alliws kanei render thn action
  # manual_csr kai emfanizei ta la8h
  def submit_csr
    @admin = Person.find_by_dn(session[:usercert])
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
    csr = RequestReader.new(params[:host_certificate_request][:body]) 
    if csr.request[:Type] == "Host"
      @csr = CertificateRequest.new(params[:host_certificate_request])
      @csr.status="pending"
      @csr.csrtype = "classic"
      @csr.uniqueid = uniqueid
      @csr.requestor_id = @admin.id
      if @csr.save
        record = @csr
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Created csr with id = " + record.id.to_s,
                    :data => record.to_yaml)
        redirect_to :action => "csr_receipt", :id =>uniqueid
      else
        render :action => "manual_csr"
      end
    else
      render :action => "manual_csr"
    end
  end

  def remove
    if params[:fqdn]
      @host = Host.find_by_fqdn(params[:fqdn])
      if @host
        if @host.admin_id != Person.find_by_dn(session[:usercert]).id
          flash[:notice] = "#{I18n.t "controllers.host.host_with_fqdn"}: " + params[:fqdn] + " #{I18n.t "controllers.host.not_under_command"}"
        elsif @host.certificate          
          flash[:notice] = "#{I18n.t "controllers.host.host_with_fqdn"}: " + params[:fqdn] + " #{I18n.t "controllers.host.has_valid_cert"}"
        else
          @host.admin_id = -1
          @host.save
          record = @host
          RegistrationLog.create( :date => DateTime.now,
                      :from => request.env['HTTP_X_FORWARDED_FOR'],
                      :person_id => session[:userid],
                      :person_dn => session[:usercert],
                      :action => "Updated host with id = " + record.id.to_s,
                      :data => record.to_yaml)
          flash[:notice] = "#{I18n.t "controllers.host.host_with_fqdn"}: " + params[:fqdn] + " #{I18n.t "controllers.host.is_deleted"}."
        end
      else
        flash[:notice] = "#{I18n.t "controllers.host.host_with_fqdn"}:" + params[:fqdn] + " #{I18n.t "controllers.host.does_not_exist"}."
      end
    end
    redirect_to :action => "list"
  end

  def find
    if params[:fqdn]
      @host = Host.find_by_fqdn(params[:fqdn])
      if @host
        redirect_to :action => "show_host_details", :id => @host.id
      else
        flash[:notice] = "#{I18n.t "controllers.host.host_with_fqdn"}: " + params[:fqdn] + " #{I18n.t "controllers.host.not_found"}."
        redirect_to :action => "list"
      end
    else
      redirect_to :action => "list"
    end
  end

  def request_administration
    if params[:fqdn]
      @host = Host.find_by_fqdn(params[:fqdn])
      if @host
        har = HostAdministrationRequest.new
        har.person = Person.find_by_dn(session[:usercert])
        har.host = @host
        har.save
        record = har
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Created HostAdministrationRequest with id = " + record.id.to_s,
                    :data => record.to_yaml)
        
        flash[:notice] = "#{I18n.t "controllers.host.req_to_manage_host"}: " + params[:fqdn] + " #{I18n.t "controllers.host.registered"}"
      else
        flash[:notice] = "#{I18n.t "controllers.host.host_with_fqdn"}: " + params[:fqdn] + " #{I18n.t "controllers.host.not_found"}"
      end
    end
    redirect_to :action => "list"
  end
  
private
  def truncate(text, length = 30, truncate_string = " ...")
    if text.nil? then return end
    l = length - truncate_string.length
    #if $KCODE == "NONE"
    #  text.length > length ? text[0...l] + truncate_string : text
    #else
    chars = text.split(//)
    chars.length > length ? chars[0...l].join + truncate_string : text
    #end
  end

end
