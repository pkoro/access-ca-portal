#!/usr/bin/env ruby
include X509Certificate;

CA_ROOT = "../" + RAILS_ROOT + "/TEST-CA"

@requests = CertificateRequest.find_all_by_status("approved")

@requests.each do |@csr|
  @requestor = Person.find(@csr.requestor_id)
  print "CSR_#{@requestor.organization.domain.upcase}.#{@csr.id}\n"
  File.open("#{RAILS_ROOT}/tmp/request.req", "w") do |f|
    f << @csr.body
  end
  if @csr.csrtype == "spkac"
    (`cd TEST-CA && /usr/bin/openssl ca -keyfile ca.key -batch -passin pass:12345 -cert ca.crt -config openssl.cnf -spkac ../tmp/request.req > /dev/null 2>&1`)
    @csr.status = "signed"
    @csr.save
  else
    (`cd TEST-CA && /usr/bin/openssl ca -keyfile ca.key -batch -passin pass:12345 -cert ca.crt -config openssl.cnf -infiles ../tmp/request.req > /dev/null 2>&1`)
    @csr.status = "signed"
    @csr.save
  end
  @@certFolder = File.expand_path("TEST-CA/newcerts/")
  cert_Files = Dir[@@certFolder + "/*.pem"]
  cert_Files.sort! {|x, y| x.downcase <=> y.downcase}
  cert_Files.each do |@certfile|
    cert=CertificateReader.new(File::read(@certfile))
    if cert.certificate[:Type]="Host"
      if cert.certificate[:Name].include?("/")
        @fqdn = cert.certificate[:Name].split("/")[1]
      else
        @fqdn = cert.certificate[:Name]
      end
      host=Host.find_by_fqdn(@fqdn)
      if host
        host.admin_id=@requestor.id
        host.save
      else
        host = UncheckedHost.create :fqdn => @fqdn,
                                    :admin_id => @requestor.id,
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
    get_cert_link = "https://srv005.grid.auth.gr/cert/get_personal_certificate/" + @csr.uniqueid
    #RegistrationMailer.deliver_notification_of_new_certificate_to_user(@requestor, crt, get_cert_link)
    File.delete(@certfile)
    File.open("#{RAILS_ROOT}/TEST-CA/index.txt", "w") do |f|
      f << ""
    end
  end
end

