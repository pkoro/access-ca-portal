require 'openssl'
require 'digest/sha1'
require 'open-uri'

module X509Certificate
  class RequestReader
    def initialize(csr)
      @valid_request=0
      @req = {}
      begin
        @req[:Object] = OpenSSL::X509::Request.new(csr)
        if @req[:Object].public_key.public_key.to_text.match(/\d+/)[0].to_i >= 1024
          @valid_request = 1
          @req[:Request_Type]="X509"
          @req[:Subject] = @req[:Object].subject
        end
      rescue OpenSSL::X509::RequestError
        @valid_request=0
      end
      if @valid_request != 1
        begin
          info, spkac = csr.split(/SPKAC=/)
          @req[:Object] = OpenSSL::Netscape::SPKI.new(spkac)
          if @req[:Object].public_key.public_key.to_text.match(/\d+/)[0].to_i >= 1024
            @valid_request = 1
            @req[:Request_Type] = "SPKAC"
            @req[:Subject] = "/" + info.chomp.gsub!(/(\r|\n)/,"/")
          end
        rescue
         @valid_request = 0
        end
      end
      
    end
    
    def valid_request
      @valid_request
    end
    
    def request
      if (isHostCertificate)
        @req[:Type] = "Host"
      else
        @req[:Type] = "Person"
      end
      @req[:dnElements] = @dnElements
      @req
    end    

    def isHostCertificate()
      subjElements = @req[:Subject].to_s.split("/")
      @dnElements={}
      is_host = false
      el_id=0
      subjElements.each do |el|
        if el!=""
          if el.include?("=")
            type, val = el.split("=")
            @dnElements[el_id]={}
            @dnElements[el_id]['Type']=type
            @dnElements[el_id]['Value']=val
          else
            el_id-=1
            @dnElements[el_id]['Value']+="/"+el
          end 
          el_id+=1
        end
      end
      @dnElements.each_value do |dnEl|
        if dnEl['Type']=="CN" 
          if dnEl['Value'][0..4]=="host/"
            is_host = true
          elsif !(/\s+/.match(dnEl['Value']))
            is_host = true
          end
        end
      end
      is_host
    end
  end
  
  class CertificateReader    
    def initialize(cert,crl="")
      if crl != "" 
        crlbody = crl
      else
        @certObj = OpenSSL::X509::Certificate.new(cert)
        caHash = @certObj.issuer.hash.to_s(base=16)
        crlFile = Dir.tmpdir + "/" + caHash + ".crl"
        if File.exist?(crlFile) and (Time.now.to_i - open(crlFile).stat.ctime.to_i) < 10
            crlbody = open(crlFile).read
        else
          case caHash
          when "ede78092"
            crlurl = "http://pki.physics.auth.gr/hellasgrid-ca/CRL/crl-v2.pem"
          when "82b36fca"
            crlurl = "http://crl.grid.auth.gr/hellasgrid-ca-2006/crl-v2.pem"
          when "28a58577"
            crlurl = "http://crl.grid.auth.gr/hellasgrid-root-ca-2006/crl-v2.pem"
          else 
            crlurl = "#{RAILS_ROOT}/crl.pem"
          end
          crlbody = open(crlurl).read
          tmpcrl = File.open(crlFile,"w")
          tmpcrl.print crlbody
          tmpcrl.close
        end
      end
      crl = OpenSSL::X509::CRL.new(crlbody)
      @serials = Array.new
      crl.revoked.each do |rev| 
        @serials << rev.serial
      end
    end
    
    def certificate
      crt = {}
      crt[:Status] = getCertificateStatus
      crt[:Type] = "Host"
      if (!isHostCertificate)
        crt[:Type] = "Person"
      end
      crt[:Subject] = @certObj.subject
      crt[:Certificate] = @certObj
      crt[:SubjAltNames] = getSubjAltNames
      @dnElements.each_value do |dnEl|
        if dnEl['Type']=="CN" 
          crt[:Name]=dnEl['Value']
        elsif dnEl['Type']=="OU"
          crt[:RA]=dnEl['Value']
        end
      end
      crt[:Serial] = @certObj.serial
      crt[:IssueDate] = @certObj.not_before
      crt[:ExpirationDate] = @certObj.not_after
      crt[:dnElements] = @dnElements
      crt
    end
    
    def isHostCertificate()
      subjElements = @certObj.subject.to_s.split("/")
      @dnElements={}
      is_host = false
      el_id=0
      subjElements.each do |el|
        if el!=""
          if el.include?("=")
            type, val = el.split("=")
            @dnElements[el_id]={}
            @dnElements[el_id]['Type']=type
            @dnElements[el_id]['Value']=val
          else
            el_id-=1
            @dnElements[el_id]['Value'] = @dnElements[el_id]['Value']+ "/" + el   
          end
          el_id+=1
        end
      end
      @dnElements.each_value do |dnEl|
        if dnEl['Type']=="CN" 
          if dnEl['Value'][0..4]=="host/"
            is_host = true
          elsif !(/\s+/.match(dnEl['Value']))
            is_host = true
          end
        end
      end
      is_host
    end
    
    def getCertificateStatus
      crtStatus = "valid"
      @now = Time::now.to_i
      if (@serials.include?(@certObj.serial))
        crtStatus = "revoked"
      elsif (@certObj.not_after.to_i < @now)
        crtStatus= "expired"
      end
      crtStatus
    end
    
    def getSubjAltNames
      subject_alt_name = @certObj.extensions.find { |ext| ext.oid == 'subjectAltName' }
      if subject_alt_name
        return subject_alt_name.value
      end
    end

    def dec2hex(num)
      dec = num.to_i
      hex = []
      i = 0
      while dec >= 1
        hex[i] = dec % 16
        dec /= 16
        i += 1
      end
      for j in 0..hex.size
        case hex[j]
        when 10
          hex[j] = "A"
        when 11
          hex[j] = "B"
        when 12
          hex[j] = "C"
        when 13
          hex[j] = "D"
        when 14
          hex[j] = "E"
        when 15
          hex[j] = "F"
        end
      end
      hex.reverse
    end
  end

	
end