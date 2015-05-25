class CaController < ApplicationController
  include X509Certificate
  include X509LoginHelper
  include SortHelper
  helper :sort
  before_filter :get_user_dn
  before_filter :check_accepted_certificate, :except => [:has_ca_access]
  before_filter :has_ca_access
  
  def index
  end
  # "#{I18n.t "controllers.ca."}"
  def manage_ra
    @action_title = "#{I18n.t "controllers.ca.manage_ra"}"
    sort_init 'registration_authorities.id','asc'
    sort_update
    @RAs = RegistrationAuthority.paginate :page => params[:page], :per_page => 30, :order => sort_clause
  end
  
  def edit_ra
    if params[:id] and RegistrationAuthority.find(params[:id])
      @ra = RegistrationAuthority.find(params[:id])
      @action_title = "Διαχείρηση Α.Τ.: " + @ra.description
      @all_organizations = Organization.find(:all)
      @selected_organizations = RegistrationAuthority.find(params[:id]).organizations.collect { |org| org.id.to_i }

      if params[:new_ra_manager] and DistinguishedName.find_by_subject_dn(params[:new_ra_manager][:dn]) 
        if RaStaffMembership.find(:all,:conditions => ["ra_id = ? and member_id = ?", params[:id], Person.find_by_dn(params[:new_ra_manager][:dn]).id]).size == 0
          membership = RaStaffMembership.new
          membership.ra_id = params[:id]
          membership.member = Person.find_by_dn(params[:new_ra_manager][:dn])
          membership.role = 1
          membership.save
          record = membership
          RegistrationLog.create( :date => DateTime.now,
                      :from => request.env['HTTP_X_FORWARDED_FOR'],
                      :person_id => session[:userid],
                      :person_dn => session[:usercert],
                      :action => "Added RA staff membership with id = " + record.id.to_s,
                      :data => record.to_yaml)
        end
      end
      
      if params[:new_ra_operator] and DistinguishedName.find_by_subject_dn(params[:new_ra_operator][:dn]) 
        if RaStaffMembership.find(:all,:conditions => ["ra_id = ? and member_id = ?", params[:id], Person.find_by_dn(params[:new_ra_operator][:dn]).id]).size == 0
          membership = RaStaffMembership.new
          membership.ra_id = params[:id]
          membership.member = Person.find_by_dn(params[:new_ra_operator][:dn])
          membership.role = 2
          membership.save
          record = membership
          RegistrationLog.create( :date => DateTime.now,
                      :from => request.env['HTTP_X_FORWARDED_FOR'],
                      :person_id => session[:userid],
                      :person_dn => session[:usercert],
                      :action => "Added RA staff membership with id = " + record.id.to_s,
                      :data => record.to_yaml)
        end
      end
    else
      redirect_to :action => "index"
    end
  end

  def remove_ra_staff
    @RAMemberTBD = RaStaffMembership.find(params[:id])
    ra_id = @RAMemberTBD.ra_id
    if @RAMemberTBD
      RaStaffMembership.delete(@RAMemberTBD.id)
    end
    redirect_to :action => "edit_ra", :id => ra_id
  end
  
  def save_ra
    if params[:ra]
      @ra = RegistrationAuthority.find(params[:ra][:id])
      if params[:ra][:organization_ids]
        @ra.organization_ids = params[:ra][:organization_ids]
      else
        @ra.organization_ids = []
      end
      @ra.description = params[:ra][:description]
      @ra.save
      record = @ra
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Saved RA with id = " + record.id.to_s,
                  :data => record.to_yaml)
    end
    redirect_to :action => "manage_ra"
  end
  
  def new_ra
    ra = RegistrationAuthority.new
    ra.description = "#{I18n.t "controllers.ca.new_ra"}"
    ra.save
    record = ra
    RegistrationLog.create( :date => DateTime.now,
                :from => request.env['HTTP_X_FORWARDED_FOR'],
                :person_id => session[:userid],
                :person_dn => session[:usercert],
                :action => "Added RA with id = " + record.id.to_s,
                :data => record.to_yaml)
    redirect_to :action => "manage_ra"
  end

  def list_pending
    @action_title = "#{I18n.t "controllers.ca.pending_req_list"}"
    sort_init 'created_at'
    sort_update
    @certificate_requests = CertificateRequest.paginate :page => params[:page], :per_page => 50, :order => sort_clause, :conditions => "status='pending'", :include => :organization
  end

  def list_approved
    respond_to do |wants|
      wants.html {
        @action_title = "#{I18n.t "controllers.ca.pending_req_to_sign"}"
        sort_init 'created_at'
        sort_update
        @certificate_requests = CertificateRequest.paginate :page => params[:page], :per_page => 50, :order => sort_clause, :conditions => "status='approved'", :include => :organization
      }
      wants.xml {
        reqs=[]
        CertificateRequest.find_all_by_status("approved").each do |@csr|
          request = Hash.new
          req = X509Certificate::RequestReader.new(@csr.body)
          if req.request[:Type] == "Host"
            alt_names = req.request[:dnElements][3]["Value"]
            if alt_names.include?("/")
              alt_names = alt_names.split("/")[1]
            end
            alt_names = "DNS.1 = " + alt_names
          else
            alt_names = "email.1 = " + Person.find(@csr.owner_id).email
          end
            request[:body] =  @csr.body
          request[:csr_type] =  @csr.csrtype
          request[:owner_type] =  req.request[:Type]
          request[:altnames] =  alt_names
          request[:uniqueid] =  @csr.uniqueid
          reqs << request
        end
        render :xml => reqs.to_xml 
      }
    end
  end
  
  def list_rejected
    @action_title = "#{I18n.t "controllers.ca.rejected_req_list"}"
    sort_init 'created_at'
    sort_update
    # @certificate_requests = CertificateRequest.paginate :page => params[:page], :order => sort_clause, :conditions => "status='rejected'", :include => :organization
    @certificate_requests = CertificateRequest.find(:all, :order => 'created_at', :conditions =>"status like 'rejected'", :include => :organization)
  end

  def show_person_details
    @action_title = "#{I18n.t "controllers.ca.user_details"}"
    @person = Person.find(params[:id])
  end

  def show_host_details
    @action_title = "#{I18n.t "controllers.ca.host_details"}"
    @host = Host.find(params[:id])
  end
  
  def show_request_details
    @action_title = "#{I18n.t "controllers.ca.req_details"}"
    @req = CertificateRequest.find(params[:id])
    @ReqReader  = RequestReader.new(@req.body)
  end

  def show_certificate_details
    @action_title = "#{I18n.t "controllers.ca.cert_details"}"
    @crt = Certificate.find(params[:id])
    @CrtReader  = CertificateReader.new(@crt.body)
  end
  
  def list_user_certificates
    @action_title = "#{I18n.t "controllers.ca.user_certs"}"
    sort_init 'certificates.updated_at','desc'
    sort_update
    # @certificates = Certificate.paginate :page => params[:page], :per_page => 20, :order => sort_clause, :joins => "inner join People on certificates.owner_id = people.id", :conditions => "certificates.owner_type = 'Person'"  
    @certificates = Certificate.find(:all, :order => 'certificates.updated_at DESC', :joins => "inner join People on certificates.owner_id = people.id", :conditions =>"certificates.owner_type like 'Person'")
  end

  def list_host_certificates
    @action_title = "#{I18n.t "controllers.ca.host_certs"}"
    sort_init 'certificates.updated_at','desc'
    sort_update
    # @certificates = Certificate.paginate :page => params[:page], :per_page => 20, :order => sort_clause, :joins => "inner join Hosts on certificates.owner_id = hosts.id", :conditions => "certificates.owner_type = 'Host'"  
    @certificates = Certificate.find(:all, :order => 'certificates.updated_at DESC', :joins => "inner join Hosts on certificates.owner_id = hosts.id", :conditions =>"certificates.owner_type like 'Host'")
  end
  
  def check_list
    @action_title = "#{I18n.t "controllers.ca.everyday_tasks"}"
    @CRLs = []
    crl = Hash.new
    crl[:CAName] = "HellasGrid CA 2002"
    crl[:url] = "http://pki.physics.auth.gr/hellasgrid-ca/CRL/crl-v2.pem"
    crl[:object] = OpenSSL::X509::CRL.new(open(crl[:url]).read)
    crl[:warning] = 23
    crl[:critical] = 16
    @CRLs << crl
    crl = Hash.new
    crl[:CAName] = "HellasGrid CA 2006"
    crl[:url] = "http://crl.grid.auth.gr/hellasgrid-ca-2006/crl-v2.pem"
    crl[:object] = OpenSSL::X509::CRL.new(open(crl[:url]).read)
    crl[:warning] = 23
    crl[:critical] = 16
    @CRLs << crl
    crl = Hash.new
    crl[:CAName] = "HellasGrid Root CA 2006"
    crl[:url] = "http://crl.grid.auth.gr/hellasgrid-root-ca-2006/crl-v2.pem"
    crl[:object] = OpenSSL::X509::CRL.new(open(crl[:url]).read)
    crl[:warning] = 30
    crl[:critical] = 23
    @CRLs << crl
    # crl = Hash.new
#     crl[:CAName] = "SEE-GRID CA"
#     crl[:url] = "http://www.grid.auth.gr/pki/seegrid-ca/services/crl/crl-v2.pem"
#     crl[:object] = OpenSSL::X509::CRL.new(open(crl[:url]).read)
#     crl[:warning] = 23
#     crl[:critical] = 16
#     @CRLs << crl
  end
  
  def upload_certs
    respond_to do |wants|
      wants.html {
        render :text=> "Uh?"
      }
      wants.xml {
        params[:records].each do |cert|
          # mark certificate request as signed
          csr = CertificateRequest.find_by_uniqueid(cert[:uniqueid])
          csr.status = "signed"
          csr.save
          
          # Load the signed certificate
          cert = CertificateReader.new(cert[:body])
          
          # If the request is for a Host check if the entity exists otherwise create it.
          if cert.certificate[:Type] == "Host"
            if cert.certificate[:Name].include?("/")
              fqdn = cert.certificate[:Name].split("/")[1]
            else
              fqdn = cert.certificate[:Name]
            end
            host = Host.find_by_fqdn(fqdn)
            if host
              host.admin_id = csr.requestor_id
              host.save
            else
              host = UncheckedHost.create :fqdn => fqdn,
                                          :admin_id => csr.requestor_id,
                                          :organization_id => Organization.find_by_fulldomain(fqdn).id,
                                          :created_at => cert.certificate[:IssueDate],
                                          :updated_at => cert.certificate[:IssueDate]
              csr.owner = host
              csr.save
            end
          end
          
          # Create a certificate record
          crt = Certificate.create  :body => cert.certificate[:Certificate].to_s,
                              :status => "not_accepted",
                              :owner_type => cert.certificate[:Type],
                              :subject_dn => cert.certificate[:Subject].to_s,
                              :owner_id => csr.owner_id,
                              :certificate_request_uniqueid => csr.uniqueid

          # Check if the DN exists otherwise create it
          dn = DistinguishedName.find_by_subject_dn(cert.certificate[:Subject].to_s)
          if ! dn
            DistinguishedName.create :subject_dn => cert.certificate[:Subject].to_s, :owner_id => csr.owner_id, :owner_type => cert.certificate[:Type]
          end

          # Check if the Subject Alternative Names exist otherwise create them
          cert.certificate[:SubjAltNames].split(/, /).each do |subjaltname|
              altname = AlternativeName.find_by_alt_name_value(subjaltname.split(/:/)[1].downcase)
              unless altname
                AlternativeName.create  :alt_name_type => subjaltname.split(/:/)[0].downcase,
                                        :alt_name_value => subjaltname.split(/:/)[1].downcase,
                                        :certificate_id => crt.id
              else
                altname.certificate = crt
                altname.save
              end
          end
          if crt.owner_type == "Person" 
            get_cert_link = "https://access.hellasgrid.gr/cert/get_personal_certificate/" + csr.uniqueid
          else
            get_cert_link = "https://access.hellasgrid.gr/cert/get_host_certificate/" + csr.uniqueid
          end
          RegistrationMailer.deliver_notification_of_new_certificate_to_user(csr.requestor, crt, get_cert_link)
          RegistrationMailer.deliver_notification_of_new_certificate_to_ra(csr.requestor, crt, get_cert_link)
        end
        render :text=>params[:records].size.to_s + " certificates were uploaded\n" 
      }
    end
  end
  
  def resend_certificate_notification
    respond_to do |wants|
      wants.html {
        render :text=> "Uh?"
      }
      wants.xml {
        @ll = ""
        params[:records].each do |cert|
          # mark certificate request as signed
          csr = CertificateRequest.find_by_uniqueid(cert[:uniqueid])
                    
          # Create a certificate record
          crt = Certificate.find_by_certificate_request_uniqueid(cert[:uniqueid])
          if crt.owner_type == "Person" 
            get_cert_link = "https://access.hellasgrid.gr/cert/get_personal_certificate/" + csr.uniqueid
          else
            get_cert_link = "https://access.hellasgrid.gr/cert/get_host_certificate/" + csr.uniqueid
          end
          RegistrationMailer.deliver_notification_of_new_certificate_to_user(csr.requestor, crt, get_cert_link)
          RegistrationMailer.deliver_notification_of_new_certificate_to_ra(csr.requestor, crt, get_cert_link)
          @ll = @ll + get_cert_link + "\n"
        end
        render :text=>"Notifications have been sent for: " + params[:records].size.to_s + " certificates\n" + @ll 
      }
    end
  end
  
private  
    def has_ca_access
      has_access=false
      if session[:userid] and Person.find(session[:userid]) and Person.find(session[:userid]).personal_certificate
        case Person.find(session[:userid]).personal_certificate.subject_dn
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Pavlos Daoglou"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=grnet.gr/CN=Kostas Koumantaros"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Christos Kanellopoulos"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Paschalis Korosoglou"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=George Fergadis"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Stefanos Laskaridis"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Nikolaos Triantafyllidis"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Alexandra Charalampidou"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Konstantina Chanioti"
          has_access=true
        when "/C=GR/O=HellasGrid/OU=auth.gr/CN=Dimitrios Folias"
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
