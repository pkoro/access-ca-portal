class Host < ActiveRecord::Base
  acts_as_versioned
  validates_presence_of   :fqdn,
                          :message => "#{I18n.t "activerecord.errors.models.host.fqdn_not_empty"}"
  validates_uniqueness_of :fqdn,
                          :message => "#{I18n.t "activerecord.errors.models.host.fqdn_used"}"
  validates_length_of     :fqdn,
                          :maximum => 254,
                          :message => "#{I18n.t "activerecord.errors.models.host.max_length"}"
  belongs_to :organization
  belongs_to :admin,
             :class_name => "Person",
             :foreign_key => "admin_id"
  has_many :distinguished_names,
           :as => :owner
  has_many :certificate_requests,
           :as => :owner
  has_many :host_administration_requests
  has_one :certificate,
          :as => :owner,
          :conditions => "created_at > to_timestamp(#{Time.now.last_year.strftime("%Y-%m-%d")}) and status = 'valid'",
          :order => 'created_at DESC'
  has_one :active_host_csr,
          :class_name => "CertificateRequest",
          :foreign_key => "owner_id",
          :conditions => "owner_type='Host' and (status = 'pending' or status = 'approved')",
          :order => "created_at DESC"
  has_one :last_certificate,
          :class_name => "Certificate",
          :foreign_key => "owner_id",
          :conditions => "owner_type='Host'",
          :order => 'created_at DESC'
  has_one :last_signed_certificate,
          :class_name => "Certificate",
          :as => :owner,
          :conditions => "created_at > to_timestamp(#{Time.now.last_year.strftime("%Y-%m-%d")}) and (status = 'valid' or status = 'not_accepted')",
          :order => 'created_at DESC'


             
    
  def validate
    organization = Organization.find(:first, :conditions => ["id = ?", organization_id])
    @isInstitutional = 0
    if fqdn =~ /#{organization.domain}/
        @isInstitutional = 1
    end
    if @isInstitutional < 1
      errors.add(:fqdn, "#{I18n.t "activerecord.errors.models.host.invalid_org"}")
    end
    IPSocket.getaddress(fqdn)
    rescue SocketError 
      errors.add(:body, "#{I18n.t "activerecord.errors.models.host.no_dns", :fqdn => fqdn}" )    
  end
end
