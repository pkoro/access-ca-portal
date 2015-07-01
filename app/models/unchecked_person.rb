class UncheckedPerson < ActiveRecord::Base
  set_table_name "people"
  acts_as_versioned(:table_name => "person_versions", :foreign_key => "person_id")
  
  has_many :certificate_requests
  has_many :distinguished_names,
           :as => :owner
  has_one :personal_certificate,
          :class_name => "Certificate",
          :foreign_key => "owner_id",
          :conditions => "created_at > to_timestamp(#{Time.now.last_year.strftime("%Y-%m-%d")}) and status = 'valid'",
          :order => 'created_at DESC'
  has_one :active_personal_csr,
          :class_name => "CertificateRequest",
          :foreign_key => "person_id",
          :conditions => "status = 'pending' or status = 'approved'",
          :order => "created_at DESC"
  belongs_to :organization

  def validate
    @organizations = Organization.find(:all).map {|o| o.domain}
    @isInstitutional = 0
    @organizations.each do |o|
      if email =~ /#{o}/ || email =~ /cern\.ch/ || email =~ /upnet\.gr/
        @isInstitutional = 1
      end
    end
    if @isInstitutional < 1
      errors.add(:email, "#{I18n.t "activerecord.errors.models.unchecked_person.institutional_mail"}")
    end
  end

  def self.find_all_by_unconfirmed_email
    find  :all,
          :conditions => ["email_confirmation = 0 and created_at > ?", 10.days.ago],
          :order => "created_at ASC"
  end
end
