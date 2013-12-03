#!/usr/bin/env ruby

RegistrationLog.find(:all, :conditions => "action='User wants newsletter?' and data='--- \"on\"\n'").each do |log|
blabla=log.id-1
  p CertificateRequest.find(RegistrationLog.find(blabla).action.split(" ")[5].to_i).owner.email
end

