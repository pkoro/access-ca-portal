#!/usr/bin/env ruby
include X509Certificate;
require_gem "sqlite3-ruby"

sqlite_file = ARGV[1] || "data.db"

if File.exist?(sqlite_file)
  File.delete(sqlite_file)
end
db = SQLite3::Database.new(sqlite_file)
db.execute("CREATE TABLE csr(body TEXT, csr_type STRING, owner_type STRING, altnames STRING, uniqueid STRING);" )

@requests = CertificateRequest.find_all_by_status("approved")
@requests.each do |@csr|
  req = X509Certificate::RequestReader.new(@csr.body)
  if req.request[:Type] == "Host"
    alt_names = req.request[:dnElements][3]["Value"]
    if alt_names.include?("/")
      alt_names = alt_names.split("/")[1]
    end
    alt_names = "DNS.1 = " + alt_names
  else
    alt_names = "email.1 = " + Person.find(@csr.owner_id).email
  end
  db.execute( "INSERT INTO csr(body, csr_type, owner_type, altnames, uniqueid) VALUES ('" + @csr.body + "','" + @csr.csrtype + "','" + req.request[:Type] + "','" + alt_names + "','" + @csr.uniqueid + "');" )
end
if db
  db.close
end
