#!/usr/bin/env ruby
require 'tmpdir'

ENV['RAILS_ENV'] = 'production'
require "/var/www/access.hellasgrid.gr/current/config/environment"
include X509Certificate

Person.find(:all).each do |p|
  if p.last_signed_certificate and (p.last_signed_certificate.status == "valid" or p.last_signed_certificate.status == "not_accepted")
    crtReader = CertificateReader.new(p.last_signed_certificate.body,"")
    if crtReader.certificate[:ExpirationDate] < 30.days.since and crtReader.certificate[:ExpirationDate] > 29.days.since
      RegistrationMailer.deliver_notification_of_user_certificate_expiration(p.last_signed_certificate,30)
	  end
    if crtReader.certificate[:ExpirationDate] < 20.days.since and crtReader.certificate[:ExpirationDate] > 19.days.since
      RegistrationMailer.deliver_notification_of_user_certificate_expiration(p.last_signed_certificate,20)
	  end
    if crtReader.certificate[:ExpirationDate] < 10.days.since and crtReader.certificate[:ExpirationDate] > 9.days.since
      RegistrationMailer.deliver_notification_of_user_certificate_expiration(p.last_signed_certificate,10)
	  end
	end
end

Host.find(:all).each do |host|
  if host.last_signed_certificate and (host.last_signed_certificate.status == "valid" or host.last_signed_certificate.status == "not_accepted")
    crtReader = CertificateReader.new(host.last_signed_certificate.body,"")
    if crtReader.certificate[:ExpirationDate] < 30.days.since and crtReader.certificate[:ExpirationDate] > 29.days.since
      RegistrationMailer.deliver_notification_of_host_certificate_expiration(host.last_signed_certificate,30)
	  end
    if crtReader.certificate[:ExpirationDate] < 20.days.since and crtReader.certificate[:ExpirationDate] > 19.days.since
      RegistrationMailer.deliver_notification_of_host_certificate_expiration(host.last_signed_certificate,20)
	  end
    if crtReader.certificate[:ExpirationDate] < 10.days.since and crtReader.certificate[:ExpirationDate] > 9.days.since
      RegistrationMailer.deliver_notification_of_host_certificate_expiration(host.last_signed_certificate,10)
	  end
	end
end
