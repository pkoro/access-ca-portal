#!/usr/bin/env ruby
require "config/environment"
include X509Certificate
expire_in_next_month = []
expire_in_next_week = []

Person.find(:all).each do |p|
  if p.last_signed_certificate and p.last_signed_certificate.status == "valid"
    crtReader = CertificateReader.new(p.last_signed_certificate.body,"")
    if crtReader.certificate[:ExpirationDate] < 1.month.since and crtReader.certificate[:ExpirationDate] > 1.week.since
		  expire_in_next_month << p.last_signed_certificate
	  end
	  if crtReader.certificate[:ExpirationDate] <= 1.week.since and crtReader.certificate[:ExpirationDate] > Time.now 
		  expire_in_next_week << p.last_signed_certificate
	  end
    if crtReader.certificate[:ExpirationDate] < 1.month.since
#	    RegistrationMailer.deliver_notification_of_user_certificate_expiration(p.last_signed_certificate,30)
    end
  end
end

Host.find(:all).each do |h|
  if h.last_signed_certificate and h.last_signed_certificate.status == "valid"
    crtReader = CertificateReader.new(h.last_signed_certificate.body,"")
    if crtReader.certificate[:ExpirationDate] < 1.month.since and crtReader.certificate[:ExpirationDate] > 1.week.since
		  expire_in_next_month << h.last_signed_certificate
	  end
	  if crtReader.certificate[:ExpirationDate] <= 1.week.since and crtReader.certificate[:ExpirationDate] > Time.now 
		  expire_in_next_week << h.last_signed_certificate
	  end
  end
end

RegistrationMailer.deliver_notification_for_expiration(expire_in_next_week, expire_in_next_month)