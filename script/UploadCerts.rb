#!/usr/bin/env ruby
include X509Certificate;
require_gem "sqlite3-ruby"

sqlite_file = ARGV[1] || "certs.db"
if File.exist?(sqlite_file)
  db = SQLite3::Database.new(sqlite_file)
  db.execute( "SELECT body, uniqueid FROM certs;" ) do |certrow|
    @csr = CertificateRequest.find_by_uniqueid(certrow[1])
    @csr.status = "signed"
    @csr.save
    cert = CertificateReader.new(certrow[0])
    if cert.certificate[:Type] == "Host"
      if cert.certificate[:Name].include?("/")
        @fqdn = cert.certificate[:Name].split("/")[1]
      else
        @fqdn = cert.certificate[:Name]
      end
      host = Host.find_by_fqdn(@fqdn)
      if host
        host.admin_id = @csr.requestor_id
        host.save
      else
        host = UncheckedHost.create :fqdn => @fqdn,
                                    :admin_id => @csr.requestor_id,
                                    :organization_id => Organization.find_by_fulldomain(@fqdn).id,
                                    :created_at => cert.certificate[:IssueDate],
                                    :updated_at => cert.certificate[:IssueDate]
        @csr.owner = host
        @csr.save
      end
    end
    Certificate.create  :body => cert.certificate[:Certificate].to_s,
                        :status => "not_accepted",
                        :owner_type => cert.certificate[:Type],
                        :subject_dn => cert.certificate[:Subject].to_s,
                        :owner_id => @csr.owner_id,
                        :certificate_request_uniqueid => @csr.uniqueid
    dn = DistinguishedName.find_by_subject_dn(cert.certificate[:Subject].to_s)
    if ! dn
      DistinguishedName.create :subject_dn => cert.certificate[:Subject].to_s, :owner_id => @csr.owner_id, :owner_type => cert.certificate[:Type]
    end
    crt = Certificate.find_by_certificate_request_uniqueid(@csr.uniqueid)
    cert.certificate[:SubjAltNames].split(/, /).each do |@SubjAltName|
        altname = AlternativeName.find_by_alt_name_value(@SubjAltName.split(/:/)[1].downcase)
        unless altname
          AlternativeName.create  :alt_name_type => @SubjAltName.split(/:/)[0].downcase,
                                  :alt_name_value => @SubjAltName.split(/:/)[1].downcase,
                                  :certificate_id => crt.id
        else
          altname.certificate = crt
          altname.save
        end
    end    
    if crt.owner_type == "Person" 
      get_cert_link = "https://access.hellasgrid.gr/cert/get_personal_certificate/" + @csr.uniqueid
    else
      get_cert_link = "https://access.hellasgrid.gr/cert/get_host_certificate/" + @csr.uniqueid
    end
    RegistrationMailer.deliver_notification_of_new_certificate_to_user(@csr.requestor, crt, get_cert_link)
    RegistrationMailer.deliver_notification_of_new_certificate_to_ra(@csr.requestor, crt, get_cert_link)
  end
  File.delete(sqlite_file)
end
