#!/usr/bin/env ruby

include X509Certificate

ActiveRecord::Base.record_timestamps = false

@hosts = Hash.new
file = File.new("#{RAILS_ROOT}/db/hosts.csv", "r")
while (line = file.gets)
  @serial, @email = line.split(/,/)
  @hosts[@serial.downcase.to_i(base=16).to_s] = [@email.downcase]
end
file.close

@organizations = UncheckedOrganization.find(:all)

@@certFolder = File.expand_path("./pem/")
@certFiles = Dir[@@certFolder + "/??.pem"].sort + Dir[@@certFolder + "/????.pem"].sort
#@certFiles.sort! {|x, y| x.downcase <=> y.downcase}

@certFiles.each do |@certfile|
  print "#{@certfile}\n"
  cr = File::read(@certfile)
  cert = CertificateReader.new(cr)
  if (cert != nil)
    @info = cert.certificate
    if (@info[:Type].to_s == 'Person') && (@info[:RA] !~ /algo/)
      print "found person cert\n"
      @email="false"
      @info[:SubjAltNames].split(/, /).each do |@SubjAltName|
        person = Person.find_by_email(@SubjAltName.split(/:/)[1].downcase)
        if person
          if person.created_at > Time.now.yesterday
            person.created_at = @info[:IssueDate]
            print "changing creation date\n"
          end
          if (person.updated_at < @info[:IssueDate]) || (person.updated_at > Time.now.yesterday)
            person.updated_at = @info[:IssueDate]
            print "changing update date\n"
          end
          person.save
          @email=@SubjAltName.split(/:/)[1].downcase
          unless DistinguishedName.find_by_subject_dn(@info[:Subject].to_s)
            dn = DistinguishedName.create :subject_dn => @info[:Subject].to_s, :owner_id => person.id, :owner_type => "Person", :created_at => @info[:IssueDate]
          end
        end
      end
      if @email=="false"
        @email = @info[:SubjAltNames].split(/, /)[0].split(/:/)[1].downcase
        @organization_id = ""
        arr = @info[:RA].split(/\./).reverse
        @ou = [arr[1], arr[0]].join(".")
        @organizations.each do |@org|
          arr = @org.domain.split(/\./).reverse
          @domain = [arr[1], arr[0]].join(".")
          if @ou == @domain
            @organization_id = @org.id
          end
        end
        @first_name_en, @last_name_en = @info[:Name].split
        UncheckedPerson.create :email => @email.downcase,
                      :first_name_en => @first_name_en,
                      :last_name_en => @last_name_en,
                      :organization_id => @organization_id,
                      :created_at => @info[:IssueDate],
                      :updated_at => @info[:IssueDate],
                      :email_confirmation => 1
        print "added person\n"
        p = UncheckedPerson.find_by_email(@email.downcase)
        dn = DistinguishedName.create :subject_dn => @info[:Subject].to_s, :owner_id => p.id, :owner_type => "Person", :created_at => @info[:IssueDate]
 	  end
 	  @person = UncheckedPerson.find_by_email(@email.downcase)
      @status = @info[:Status]
 	  uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
 	  crt = Certificate.create  :body => @info[:Certificate].to_s,
 	                            :status => @status,
 	                            :owner_type => "Person",
 	                            :subject_dn => @info[:Subject].to_s,
 	                            :owner_id => @person.id,
 	                            :created_at => @info[:IssueDate],
 	                            :updated_at => @info[:IssueDate],
 	                            :certificate_request_uniqueid => uniqueid
      print "added Certificate\n"
 	  @info[:SubjAltNames].split(/, /).each do |@SubjAltName|
        AlternativeName.create  :alt_name_type => @SubjAltName.split(/:/)[0].downcase,
                                :alt_name_value => @SubjAltName.split(/:/)[1].downcase,
                                :certificate_id => crt.id
        print "added Alternate Name\n"
      end
 	elsif @info[:RA] !~ /algo/
      print "found host cert\n"
      @dns="false"
      @info[:SubjAltNames].split(/, /).each do |@SubjAltName|
        host = UncheckedHost.find_by_fqdn(@SubjAltName.split(/:/)[1])
        if host
          if host.created_at > Time.now.yesterday
            host.created_at = @info[:IssueDate]
            print "changing creation date\n"
          end
          if (host.updated_at < @info[:IssueDate]) || (host.updated_at > Time.now.yesterday)
            host.updated_at = @info[:IssueDate]
            print "changing update date\n"
          end
          host.save
          @dns=host.fqdn
          @organization_id = host.organization_id
        end
      end
      if @dns=="false"
        @dns = @info[:SubjAltNames].split(/, /)[0].split(/:/)[1].downcase
        @organization_id = ""
        arr = @dns.split(/\./).reverse
        @ou = [arr[1], arr[0]].join(".")
        @organizations.each do |@org|
          arr = @org.domain.split(/\./).reverse
          @domain = [arr[1], arr[0]].join(".")
          if @ou == @domain
            @organization_id = @org.id
          end
        end
      end
      if @hosts[@info[:Serial].to_s]
        admin = Person.find_by_email(@hosts[@info[:Serial].to_s][0].to(@hosts[@info[:Serial].to_s][0].length-2).downcase)
      end
      if admin
        admin_id=admin.id
      else
        admin_id=0
      end
 	  host = Host.find_by_fqdn(@dns)
      if host
        host.admin_id=admin_id
        host.save
        print "updated host\n"
      else
        host = UncheckedHost.create :fqdn => @dns,
                                    :admin_id => admin_id,
                                    :organization_id => @organization_id,
                                    :created_at => @info[:IssueDate],
                                    :updated_at => @info[:IssueDate]
        print "added host\n"
      end
      unless DistinguishedName.find_by_subject_dn(@info[:Subject].to_s)
        dn = DistinguishedName.create :subject_dn => @info[:Subject].to_s, :owner_id => host.id, :owner_type => "Host", :created_at => @info[:IssueDate]
      end
 	  if @info[:IssueDate] > Time.now.last_year
 	    @status = "valid"
 	  else
 	    @status = "expired"
 	  end
 	  uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
      crt = Certificate.create  :body => @info[:Certificate].to_s,
 	                            :status => @status,
 	                            :owner_type => "Host",
 	                            :subject_dn => @info[:Subject].to_s,
 	                            :owner_id => host.id,
                                :created_at => @info[:IssueDate],
 	                            :updated_at => @info[:IssueDate],
 	                            :certificate_request_uniqueid => uniqueid
 	  @info[:SubjAltNames].split(/, /).each do |@SubjAltName|
        AlternativeName.create  :alt_name_type => @SubjAltName.split(/:/)[0].downcase,
                                :alt_name_value => @SubjAltName.split(/:/)[1].downcase,
                                :certificate_id => crt.id
        print "added Alternate Name\n"
      end
    end
  end
end