module SupportHelper
  def create_csr_list_row(csr, i)
    row_class = i%2 == 0 ? "even" : "odd" 
    @fqdn = X509Certificate::RequestReader.new(csr.body).request[:dnElements][3]["Value"]
    if @fqdn.include?("/")
      @fqdn = @fqdn.split("/")[1]
    end
    result = "<tr class=" + row_class + ">"
    result += "<td>CSR_" + csr.organization.domain.upcase + "_" + csr.id.to_s + "</td>"
    if csr.owner_type == "Person"
      result += "<td>" + link_to(csr.owner.email, :action => 'show_person_details', :id => csr.owner) + "</td>"
    else
      @host = Host.find_by_fqdn(@fqdn)
      if @host
        if csr.owner_id == 0
          csr.owner = @host
          csr.save
          record = csr
          RegistrationLog.create( :date => DateTime.now,
                      :from => request.env['HTTP_X_FORWARDED_FOR'],
                      :person_id => session[:userid],
                      :person_dn => session[:usercert],
                      :action => "Updated owner of CSR with id = " + record.id.to_s,
                      :data => record.to_yaml)
        end
        result += "<td>" + link_to(@fqdn, :controller => 'host', :action => 'show_host_details', :id => csr.owner) + "</td>"
      else
        result += "<td>" + @fqdn + "</td>"
      end      
    end
	result += "<td>" + csr.status + "</td>"
	result += "<td>" + csr.created_at.mday.to_s + "/" + csr.created_at.month.to_s + "/" + csr.created_at.year.to_s + "</td>"
	result += "</tr>"
	result
  end
end
