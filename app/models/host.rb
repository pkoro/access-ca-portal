class Host < ActiveRecord::Base
  acts_as_versioned
  validates_presence_of   :fqdn,
                          :message => "^ Η FQDN διεύθυνση δεν πρέπει να είναι κενή"
  validates_uniqueness_of :fqdn,
                          :message => "^ Η FQDN διεύθυνση χρησιμοποιείται ήδη.  Αν επιθυμείτε να αναλάβετε την διαχείρηση του θα πρέπει να επικοινωνήστε με την <a href='mailto:support@grid.auth.gr?subject=Αίτηση αλλαγής διαχειρηστή διακομιστή&body=Θέλω να αναλάβω την διαχείρηση του διακομιστή'>ομάδα υποστήριξης</a>"
  validates_length_of     :fqdn,
                          :maximum => 254,
                          :message => "^ Το μέγιστο μεγεθος της καταχώρησης για το κάθε πεδίο είναι 254 χαρακτήρες"
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
      errors.add(:fqdn, "^ Η διεύθυνση του διακομιστή δεν ανοίκει στο οργανισμό που έχετε δηλώσει")
    end
    IPSocket.getaddress(fqdn)
    rescue SocketError 
      errors.add(:body, "^ Το host '" + fqdn + "' δεν είναι δηλωμένο στον διακομιστή DNS" )    
  end
end
