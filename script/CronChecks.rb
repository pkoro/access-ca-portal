#!/usr/bin/env ruby

require "./config/environment"

include X509Certificate
#sync certificate status
Certificate.find(:all, :conditions => ["status = 'valid'"]).each {|crt|
  crtReader = X509Certificate::CertificateReader.new(crt.body,"")
  if crtReader.certificate[:Status] == "expired"
    crt.status="expired"
    crt.save
    RegistrationLog.create( :date => DateTime.now,
                :from => "localhost",
                :person_id => nil,
                :person_dn => nil,
                :action => "Expired certificate with id = " + crt.id.to_s,
                :data => crt.to_yaml)
  elsif crtReader.certificate[:Status] == "revoked"
    crt.status="revoked"
    crt.save
    RegistrationLog.create( :date => DateTime.now,
                :from => "localhost",
                :person_id => nil,
                :person_dn => nil,
                :action => "Revoked certificate with id = " + crt.id.to_s,
                :data => crt.to_yaml)
  end
  crtReader =""
}

#Retire hosts that haven't a valid certificate for more than 180 days (~ six months)
#Host.find(:all, :conditions => ["admin_id > -1"]).each {|host| 
#  if host.last_certificate
#    if ((DateTime.now - X509Certificate::CertificateReader.new(host.last_certificate.body).certificate[:ExpirationDate].to_s.to_date).to_i > 180)
#      host.admin_id = -1
#      host.save
#    end
#  end
#}

#Host.find(:all, :conditions => ["admin_id > -1"]).each {|host| 
#  if host.last_certificate
#    if ((DateTime.now - X509Certificate::CertificateReader.new(host.last_certificate.body).certificate[:ExpirationDate].to_s.to_date).to_i > 180)
#      print host.fqdn + "\n"
#    end
#  end
#}
