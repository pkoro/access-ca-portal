#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'production'
require "/var/www/access.hellasgrid.gr/current/config/environment"

organizations = "('false'"
RaOrganizationRelation.find(:all,:conditions=>["ra_id = ?",14]).each {|rel| organizations += " OR organization_id = "+  rel.organization_id.to_s}
organizations += ")"

certificate_requests = CertificateRequest.find(:all,:conditions =>(organizations + " AND status='pending' AND owner_type='Person'"))

pending_requests = ""
certificate_requests.each do |cert_req|
  # O account και ο host controller (x509 authentication) κάνουν log: Created csr with id 
  # Ο register (email authentication) κάνει log: Created CSR with id 
  if cert_req.owner.last_id_check_on? && cert_req.owner.last_id_check_on > 5.years.ago && !RegistrationLog.find(:first, :conditions =>["action = 'Created csr with id = ?'",cert_req.id]).nil?
    pending_requests += cert_req.owner.email + ", https://access.hellasgrid.gr/ra/show_request_details/" + cert_req.id.to_s + "\n"
  end
end

if pending_requests != "" then
  RegistrationMailer.deliver_notification_of_pending_requests(pending_requests)
end
