module RaHelper
  def create_csr_list_row(csr, i)
    row_class = i%2 == 0 ? "even" : "odd"
    @fqdn = X509Certificate::RequestReader.new(csr.body).request[:dnElements][X509Certificate::RequestReader.new(csr.body).request[:dnElements].size - 1]["Value"]
    if @fqdn.include?("/")
      @fqdn = @fqdn.split("/")[1]
    end
    result = "<tr class='" + row_class + "'>"
    if X509Certificate::RequestReader.new(csr.body).request[:Type] == "Host"
      result += "<td>" + link_to("CSR_"+Organization.find_by_fulldomain(@fqdn).domain.upcase + "_" + csr.id.to_s, :action => 'show_request_details', :id => csr.id) + "</td>"
      result += "<td>Host</td>"
      if csr.owner_id != 0 then
        result += "<td>"+ link_to(csr.owner.fqdn, :action => 'show_host_details', :id => csr.owner.id) + "</td>"
      else
        result += "<td>" + @fqdn + "</td>"
      end
      result += "<td>" + Organization.find_by_fulldomain(@fqdn).name_el + "</td>"
    else
      result += "<td>" + link_to("CSR_" + csr.owner.organization.domain.upcase + "_" + csr.id.to_s, :action => 'show_request_details', :id => csr.id)+ "</td>"
      result += "<td>Person</td>"
      result += "<td>" + link_to(csr.owner.email, :action => 'show_person_details', :id => csr.owner.id) + "</td>"
      result += "<td>" + csr.owner.organization.name_el + "</td>"
    end
    result += "<td>" + csr.created_at.mday.to_s + "/" +  csr.created_at.month.to_s + "/" + csr.created_at.year.to_s + "</td>"
    result += "<td>"
    if csr.requestor.first_name_en.empty? or csr.requestor.last_name_en.empty? then
      result += csr.requestor.first_name_el + " " + csr.requestor.last_name_el
    else
      result += csr.requestor.first_name_en + " " + csr.requestor.last_name_en
    end
    if csr.requestor.work_phone and csr.requestor.work_phone.size != 0 
      result += " (" + csr.requestor.work_phone + ")"
    end
    result += "</td>"
    result += "</tr>"
    result
  end
  
  def create_approved_csr_list_row(csr, i) 
    row_class = i%2 == 0 ? "even" : "odd"
    @fqdn = X509Certificate::RequestReader.new(csr.body).request[:dnElements][X509Certificate::RequestReader.new(csr.body).request[:dnElements].size - 1]["Value"]
    if @fqdn.include?("/")
      @fqdn = @fqdn.split("/")[1]
    end
    result = "<tr class='" + row_class + "'>"
    if X509Certificate::RequestReader.new(csr.body).request[:Type] == "Person"
      person = csr.owner
      result += "<td>CSR_" + person.organization.domain.upcase + "_" + csr.id.to_s + "</td>"
      result += "<td>" + link_to(person.email, :action => 'show_person_details', :id => person) + "</td>"
      result += "<td>" + person.organization.name_el + "</td>"
    else
      result += "<td>CSR_" + Organization.find_by_fulldomain(@fqdn).domain.upcase + "_" + csr.id.to_s + "</td>"
      if csr.owner_id != 0
        result += "<td>" + link_to(@fqdn, :action => 'show_host_details', :id => Host.find_by_fqdn(@fqdn).id) + "</td>"
      else
        result += "<td>" + @fqdn + "</td>"
      end
      result += "<td>" + Organization.find_by_fulldomain(@fqdn).name_el + "</td>"      
    end
    result += "<td>" + csr.created_at.mday.to_s + "/" + csr.created_at.month.to_s + "/" + csr.created_at.year.to_s + "</td>"
    result += "<td>" + csr.updated_at.mday.to_s + "/" + csr.updated_at.month.to_s + "/" + csr.updated_at.year.to_s + "</td>"
    result += "</tr>"
    result
  end
end