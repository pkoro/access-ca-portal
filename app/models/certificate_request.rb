class CertificateRequest < ActiveRecord::Base
  include X509Certificate
  require 'resolv'
  
  belongs_to :requestor,
             :class_name => "Person",
             :foreign_key => "requestor_id"
  belongs_to :owner, :polymorphic => true
  belongs_to :ra,
             :class_name => "Person",
             :foreign_key => "ra_id"
  belongs_to :organization
  
  def validate_on_create
    csr = RequestReader.new(body)
    host = nil
    if csr.valid_request != 1
      errors.add(:body, "^ Η αίτηση πιστοποιητικού δεν είναι έγκυρη!")
    elsif csr.request[:dnElements].size != 4
      errors.add(:body, "^ Η αίτηση πιστοποιητικού πρέπει να έχει την δομή: /C=GR/O=HellasGrid/OU=&lt;domain name&gt;/CN=&lt;User's Fullname OR Host's FQDN&gt;")
    else
      if csr.request[:dnElements][0]['Type'] != "C" 
        errors.add(:body, "^ Το πρώτο πεδίο του DN της αίτησης πρέπει να είναι το πεδίο C (Country)")
      end
      if csr.request[:dnElements][1]['Type'] != "O"
        errors.add(:body, "^ Το δεύτερο πεδίο του DN της αίτησης πρέπει να είναι το πεδίο O (Organization)")
      end
      if csr.request[:dnElements][2]['Type'] != "OU"
        errors.add(:body, "^ Το τρίτο πεδίο του DN της αίτησης πρέπει να είναι το πεδίο OU (Organization Unit)")
      end
      if csr.request[:dnElements][3]['Type'] != "CN"
        errors.add(:body, "^ Το τέταρτο πεδίο του DN της αίτησης πρέπει να είναι το πεδίο CN (Common Name)")
      end
      if csr.request[:dnElements][0]['Value'] != "GR"
        errors.add(:body, "^ Η τιμή του πρώτου πεδίου του DN της αίτησης πρέπει να είναι C=GR")
      end
      if csr.request[:dnElements][1]['Value'] != "HellasGrid" and csr.request[:dnElements][1]['Value'] != "Invalid HellasGrid"
        errors.add(:body, "^ Η τιμή του δεύτερου πεδίου του DN της αίτησης πρέπει να είναι O=HellasGrid")
      end
      self.owner_type = csr.request[:Type]
      if self.owner_type == "Person"
        # check if there is an active CSR for the use
        existing_csr = CertificateRequest::find_active_personal_csr_for_person(self.owner_id)
        if existing_csr
          errors.add(:body, "^ Έχετε ήδη μια αίτηση πιστοποιητικού σε εκκρεμότητα")
        end
        self.organization = self.owner.organization
      else
        csr.request[:dnElements].each_value do |dnEl|
          if dnEl['Type']=="CN" 
            if dnEl['Value'].include?("/")
              @fqdn = dnEl['Value'].split("/")[1]
            else
              @fqdn = dnEl['Value']
            end
          end
        end
        IPSocket.getaddress(@fqdn)
        host = Host.find_by_fqdn(@fqdn)
        self.organization = Organization.find_by_fulldomain(@fqdn)
        if host
          self.owner_id = host.id
        else
          self.owner_id = 0
        end
      end
    end
    rescue SocketError 
      errors.add(:body, "^ Το όνομα διακομιστή '" + @fqdn + "' δεν είναι δηλωμένο στον διακομιστή DNS")
  end

  def self.find_active_personal_csr_for_person(id)
    find  :first,
          :conditions => ["owner_id = ? and owner_type='Person' and (status = 'pending' or status = 'approved')", id],
          :order => "created_at DESC"
  end
end
