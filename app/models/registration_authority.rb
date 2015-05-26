class RegistrationAuthority < ActiveRecord::Base
  validates_presence_of   :description,
                          :message => "#{I18n.t "activerecord.errors.models.registration_authority.desc_not_empty"}"
  has_many :ra_staff_memberships,
           :foreign_key => "ra_id"
  has_and_belongs_to_many :organizations,
                          :join_table => "ra_organization_relations",
                          :foreign_key => "ra_id",
                          :association_foreign_key => "organization_id"
  belongs_to :organization
                 
  def find_pending_ra_requests
    @organizations = "('false'"
    RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",self.id]).each {|rel| @organizations += " OR organization_id = "+  rel.organization_id.to_s}
    @organizations += ")"
    CertificateRequest.find  :all,
          :conditions => [@organizations + " AND status = 'pending'"],
          :order => "created_at DESC"
  end
  
  def find_pending_host_adminstration_requests
    HostAdministrationRequest.find :all,
             :include => { :host => { :organization => { :ra_organization_relations => :registration_authority } } }, 
             :conditions=> ["registration_authorities.id = 1"],
             :order => "hosts.fqdn DESC"
  end
end
