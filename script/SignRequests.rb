#!/usr/bin/env ruby
require 'rubygems'
gem 'hpricot'
gem 'activesupport'
require 'hpricot'
require 'ActiveSupport'

begin
  csrs_xml = ARGV[0] || "csrs.xml"
  if File.exist?(csrs_xml)
    ca_folder = ARGV[1] || "."
    temporary_folder = ARGV[2] || "/tmp/"
    certs_xml = ARGV[3] || "certs.xml"
    if File.exist?(certs_xml)
      File.delete(certs_xml)
    end
    csrs = Hpricot.XML(open(csrs_xml))
    certs = []
    (csrs/:record).each do |csr|
      if (csr/:"owner-type").inner_html == "Person"
        @CertKeyUsage = "keyUsage               = critical, nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment"
      elsif (csr/:"owner-type").inner_html == "Host"
        @CertKeyUsage = "keyUsage               = critical, digitalSignature, keyEncipherment, dataEncipherment"
      end
      File.open(temporary_folder + "/HGcsr", "w") do |f|
        f << (csr/:body).inner_html
      end
      File.open(temporary_folder + "/HGssl.cnf","w") do |f|
        f << '[ ca ]
default_ca = "HG"

[ HG ]
private_key = "' + ca_folder + '/ca.key"
certificate = "' + ca_folder + '/ca.crt"
database = "' + ca_folder + '/index.txt"
serial = "'+ ca_folder + '/serial"
unique_subject  = no
default_md = sha1
default_crl_days = 30
default_days = 365
crl_extensions = crl_ext
new_certs_dir = "' + temporary_folder + '"
policy = "HG_policy"
x509_extensions = "cert_ext"

[ crl_ext ]
authorityKeyIdentifier=keyid:always,issuer:always

[ HG_policy ]
countryName             = match
organizationName        = supplied
organizationalUnitName  = supplied
commonName              = supplied

[ cert_ext ]
basicConstraints       = critical,CA:FALSE
' + @CertKeyUsage + '
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer:always
issuerAltName          = email:hellasgrid-ca@grid.auth.gr
subjectAltName         = @altnames

[ altnames ]
' + (csr/:altnames).inner_html + '
'
      end
      @CertFile = temporary_folder + "/" + File::read(ca_folder + "/serial").chomp + ".pem"
      if (csr/:"csr-type").inner_html == "spkac"
        (`/usr/bin/openssl ca -batch -passin pass:12345 -config /tmp/HGssl.cnf -spkac /tmp/HGcsr  > /dev/null 2>&1`)
      else
        (`/usr/bin/openssl ca -batch -passin pass:12345 -config /tmp/HGssl.cnf -infiles /tmp/HGcsr > /dev/null 2>&1`)
      end
      cert=Hash.new
      cert[:body]=File::read(@CertFile)
      cert[:uniqueid]=(csr/:uniqueid).inner_html
      certs << cert
      File.delete(@CertFile)
      File.delete(temporary_folder + "/HGcsr")
      File.delete(temporary_folder + "/HGssl.cnf")
    end
    File.open(certs_xml, "w") do |f|
      f << certs.to_xml
    end
    
  end
end
