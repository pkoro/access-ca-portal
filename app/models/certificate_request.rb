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
      errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.invalid_cert_req"}")
    elsif csr.request[:dnElements].size != 4
      errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.csr_structure"}")
    else
      if csr.request[:dnElements][0]['Type'] != "C" 
        errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.first_csr_field"}")
      end
      if csr.request[:dnElements][1]['Type'] != "O"
        errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.second_csr_field"}")
      end
      if csr.request[:dnElements][2]['Type'] != "OU"
        errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.third_csr_field"}")
      end
      if csr.request[:dnElements][3]['Type'] != "CN"
        errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.fourth_csr_field"}")
      end
      if csr.request[:dnElements][0]['Value'] != "GR"
        errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.first_csr_field_val"}")
      end
      if csr.request[:dnElements][1]['Value'] != "HellasGrid" and csr.request[:dnElements][1]['Value'] != "Invalid HellasGrid"
        errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.second_csr_field_val"}")
      end
      self.owner_type = csr.request[:Type]
      if self.owner_type == "Person"
        # check if there is an active CSR for the use
        existing_csr = CertificateRequest::find_active_personal_csr_for_person(self.owner_id)
        if existing_csr
          errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.existing_req"}")
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
      errors.add(:body, "#{I18n.t "activerecord.errors.models.certificate_request.unregistered_dns"}", :fqdn => @fqdn)
  end

  def self.find_active_personal_csr_for_person(id)
    find  :first,
          :conditions => ["owner_id = ? and owner_type='Person' and (status = 'pending' or status = 'approved')", id],
          :order => "created_at DESC"
  end
end
