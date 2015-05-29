class RaController < ApplicationController
  include X509Certificate
  include X509LoginHelper
  include SortHelper
  helper :sort
  before_filter :get_user_dn
  before_filter :check_accepted_certificate #, :except => [:has_ra_access]
  before_filter :has_ra_access
  
  def index
  end

  def list_pending
    @organizations = "('false'"
    RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",@ra_membership.ra_id]).each {|rel| @organizations += " OR organization_id = "+  rel.organization_id.to_s}
    @organizations += ")"
    @action_title = "#{I18n.t "controllers.ca.pending_req_list"}"
    sort_init 'created_at'
    sort_update
    # @certificate_requests = CertificateRequest.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :conditions => @organizations + " AND status='pending'", :include => :organization
    @certificate_requests = CertificateRequest.find(:all, :order => 'created_at', :conditions => @organizations + " AND status='pending'", :include => :organization)
    
  end

  def list_approved
    @organizations = "('false'"
    RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",@ra_membership.ra_id]).each {|rel| @organizations += " OR organization_id = "+  rel.organization_id.to_s}
    @organizations += ")"
    @action_title = "#{I18n.t "controllers.ca.pending_req_to_sign"}"
    sort_init 'created_at'
    sort_update
    # @certificate_requests = CertificateRequest.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :conditions =>        @organizations + " AND status='approved'", :include => :organization
    @certificate_requests = CertificateRequest.find(:all, :order => 'created_at', :conditions => @organizations + " AND status='approved'", :include => :organization)
  end

  def list_rejected
    @organizations = "('false'"
    RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",@ra_membership.ra_id]).each {|rel| @organizations += " OR organization_id = "+  rel.organization_id.to_s}
    @organizations += ")"
    @action_title = "#{I18n.t "controllers.ca.rejected_req_list"}"
    sort_init 'created_at'
    sort_update
    # @certificate_requests = CertificateRequest.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :conditions => @organizations + " AND status='rejected'", :include => :organization
    @certificate_requests = CertificateRequest.find(:all, :order => 'created_at', :conditions => @organizations + " AND status='rejected'", :include => :organization)
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
    @req = CertificateRequest.find(params[:id].to_i.to_s)
    @ReqReader  = RequestReader.new(@req.body)
    if !RegistrationAuthority.find(@ra_membership.ra_id).organizations.exists?(@req.organization.id)
      redirect_to :action => "index"
    end
  end

  def show_certificate_details
    @action_title = "#{I18n.t "controllers.ca.cert_details"}"
    @crt = Certificate.find(params[:id])
    @CrtReader  = CertificateReader.new(@crt.body)
  end
  
  def manage_operators
    @action_title = "#{I18n.t "controllers.ca.manage_ra"}"
    sort_init 'role'
    sort_update
    @ra_membership = RaStaffMembership.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :joins => "inner join People on ra_staff_memberships.member_id = people.id", :conditions => ["ra_id = ?", @ra_membership.ra_id]
  end
  
  def accept_csr
    if params[:checked_req] == "on"
      @req = CertificateRequest.find(params[:request])
      if @req.owner_type =="Host" or params[:checked_id] == "on"
        if @req and (RegistrationAuthority.find(@ra_membership.ra_id).organizations.exists?(@req.organization.id))
          @req.ra = Person.find(session[:userid])
          @req.status = "approved"
          if params[:checked_id] == "on" && @req.owner_type == "Person"
            @req.owner.id_check_by = @req.ra
            @req.owner.last_id_check_on = Date.today.to_s(:db)
            @req.owner.save_without_validation
            record = @req.owner
            RegistrationLog.create( :date => DateTime.now,
                        :from => request.env['HTTP_X_FORWARDED_FOR'],
                        :person_id => session[:userid],
                        :person_dn => session[:usercert],
                        :action => "Checked id of entity with id = " + record.id.to_s,
                        :data => record.to_yaml)
          end
          @req.save
          record = @req
          RegistrationLog.create( :date => DateTime.now,
                      :from => request.env['HTTP_X_FORWARDED_FOR'],
                      :person_id => session[:userid],
                      :person_dn => session[:usercert],
                      :action => "Appproved csr with id = " + record.id.to_s,
                      :data => record.to_yaml)
          RegistrationMailer.deliver_notification_of_csr_approvement(@req, url_for(:controller => "ca", :action => "show_request_details", :id => @req.id))
        end
      elsif @req.owner.last_id_check_on? && @req.owner.last_id_check_on > 5.years.ago
        @req.ra = Person.find(session[:userid])
        @req.status = "approved"
        @req.save
        record = @req
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Appproved csr with id = " + record.id.to_s,
                    :data => record.to_yaml)
        RegistrationMailer.deliver_notification_of_csr_approvement(@req, url_for(:controller => "ca", :action => "show_request_details", :id => @req.id))
      end
      if params[:newsletter]
        record = params[:newsletter]
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "User wants newsletter?",
                    :data => record.to_yaml)
      end
    end
    redirect_to :action => "list_pending"
  end
  
  def reject_csr
    @req = CertificateRequest.find(params[:request])
    if @req and (RegistrationAuthority.find(@ra_membership.ra_id).organizations.exists?(@req.organization.id))
      @req.ra = Person.find(session[:userid])
      @req.status = "rejected"
      @req.save
      record = @req
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Rejected csr with id = " + record.id.to_s,
                  :data => record.to_yaml)
      
    end
    redirect_to :action => "list_pending"
  end

  def add_ra_operator
    if DistinguishedName.find_by_subject_dn(params[:ra_access][:dn]) 
      if RaStaffMembership.find(:all,:conditions => ["ra_id = ? and member_id = ?", @ra_membership.ra_id, Person.find_by_dn(params[:ra_access][:dn]).id]).size == 0 and @ra_membership.role == 1
        membership = RaStaffMembership.new
        membership.ra_id = @ra_membership.ra_id
        membership.member = Person.find_by_dn(params[:ra_access][:dn])
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
    redirect_to :action => "manage_operators"
  end

  def remove_ra_operator
    @RAMemberTBD = RaStaffMembership.find(:first, :conditions => ["member_id = ? and ra_id = ? and role = 2", params[:id], @ra_membership.ra_id])
    if @RAMemberTBD and @ra_membership.role == 1
      record = @RAMemberTBD
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Deleted RA staff membership with id = " + record.id.to_s,
                  :data => record.to_yaml)
      RaStaffMembership.delete(@RAMemberTBD.id)
    end
    redirect_to :action => "manage_operators"
  end

  def list_user_certificates
    @organizations = "('false'"
    RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",@ra_membership.ra_id]).each {|rel| @organizations += " OR organization_id = "+  rel.organization_id.to_s}
    @organizations += ")"
    @action_title = "#{I18n.t "controllers.ca.user_certs"}"
    sort_init 'certificates.updated_at','desc'
    sort_update
    # @certificates = Certificate.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :joins => "inner join People on certificates.owner_id = people.id", :conditions => @organizations + " AND certificates.owner_type = 'Person'"
    @certificates = Certificate.find(:all, :order => 'certificates.updated_at DESC', :joins => "inner join People on certificates.owner_id = people.id", :conditions => @organizations + " AND certificates.owner_type = 'Person'")
  end

  def list_host_certificates
    @organizations = "('false'"
    RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",@ra_membership.ra_id]).each {|rel| @organizations += " OR organization_id = "+  rel.organization_id.to_s}
    @organizations += ")"
    @action_title = "#{I18n.t "controllers.ca.host_certs"}"
    sort_init 'certificates.updated_at','desc'
    sort_update
    # @certificates = Certificate.paginate :page=>params[:page], :per_page => 20, :order => sort_clause, :joins => "inner join Hosts on certificates.owner_id = hosts.id", :conditions => @organizations + " AND certificates.owner_type = 'Host'"
    @certificates = Certificate.find(:all, :order => 'certificates.updated_at DESC', :joins => "inner join Hosts on certificates.owner_id = hosts.id", :conditions => @organizations + " AND certificates.owner_type = 'Host'")
  end
  
  def fail
    #ayto prepei kai kanei fail!
    @ra = RegistrationAuthority.find(@ra_membership.ra_id).size
  end
  
  private
    def has_ra_access
      has_access=false
      if session[:userid] 
        @ra_membership = RaStaffMembership.find_by_member_id(session[:userid])
        if @ra_membership
          @ra = RegistrationAuthority.find(@ra_membership.ra_id)
          has_access=true
        else
          has_access=false
        end
      else
        has_access=false
      end
      if !has_access
        redirect_to :controller => "register", :action => "index" unless performed? 
      end
    end
end
