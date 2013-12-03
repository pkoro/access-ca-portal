module AccountHelper
  def create_csr_list_row(csr, i)
    row_class = i%2 == 0 ? "even" : "odd"    
    @fqdn = X509Certificate::RequestReader.new(csr.body).request[:dnElements][3]["Value"]
    if @fqdn.include?("/")
      @fqdn = @fqdn.split("/")[1]
    end
    result = "<tr class='" + row_class + "'>"
    if X509Certificate::RequestReader.new(csr.body).request[:Type] == "Host"
      result += "<td>" + link_to("CSR_"+ csr.organization.domain.upcase + "_" + CertificateRequest.find_by_uniqueid(csr.uniqueid).id.to_s, :controller => 'cert', :action => 'show_request_details', :id => CertificateRequest.find_by_uniqueid(csr.uniqueid).id) + "</td>"
      result += "<td>Host</td>"
      if csr.owner_id != 0 then
        result += "<td>"+ link_to(csr.owner.fqdn, :controller => 'host' ,:action => 'show_host_details', :id => csr.owner.id) + "</td>"
      else
        result += "<td>" + @fqdn + "</td>"
	  end
      result += "<td>" + csr.organization.name_el + "</td>"
    else
      result += "<td>" + link_to("CSR_" + csr.organization.domain.upcase + "_" + CertificateRequest.find_by_uniqueid(csr.uniqueid).id.to_s, :controller => 'cert', :action => 'show_request_details', :id => CertificateRequest.find_by_uniqueid(csr.uniqueid).id)+ "</td>"
      result += "<td>Person</td>"
      result += "<td>" + link_to(csr.owner.email, :action => 'show_person_details', :id => csr.owner.id) + "</td>"
      result += "<td>" + csr.organization.name_el + "</td>"
    end
    result += "<td>" + csr.created_at.mday.to_s + "/" +  csr.created_at.month.to_s + "/" + csr.created_at.year.to_s + "</td>"
    result += "<td>" + csr.status + "</td>"
    result += "</tr>"
    result
  end
end
