class CertController < ApplicationController
  include X509LoginHelper
  before_filter :get_user_dn
  # "#{I18n.t "controllers.cert."}"
  def index
    redirect_to :action => "search_crt"
  end
  
  def monitor_request
    @action_title = "#{I18n.t "controllers.cert.watch_cert_req"}"
    uniqueid = params[:id]
    if uniqueid
      @csr = CertificateRequest.find_by_uniqueid(uniqueid)
      if @csr && @csr.status == "signed"
        @crt = Certificate.find_by_certificate_request_uniqueid(uniqueid)
        if @crt.owner_type == "Person"
          @get_cert_link = url_for :action => "get_personal_certificate", :id => uniqueid
        else
          @get_cert_link = url_for :action => "download_cert", :id => uniqueid
        end
      end
      render(:template => "cert/monitor_request_results")
    end
  end
  
  def search_crt
    @action_title = "#{I18n.t "controllers.cert.search_cert"}"
  end
  
  def search_crt_results
    if params[:cert] && params[:cert]['alt_name']
      @action_title = "Αποτελέσματα αναζήτησης πιστοποιητικού"
      @person = Person.find_by_email(params[:cert]['alt_name'])
      @host = Host.find_by_fqdn(params[:cert]['alt_name'])
      if @person
        @cert = @person.last_signed_certificate
      elsif @host
        @cert = @host.last_signed_certificate
      end
      if @cert
        @cert_reader = X509Certificate::CertificateReader.new(@cert.body)
      end
    else
      redirect_to :action => "search_crt"
    end
  end
  
  def load_cert
    uniqueid = params[:id]
    crt = Certificate.find_by_certificate_request_uniqueid(uniqueid)
    send_data(crt.body, :type => "application/x-x509-user-cert", :disposition => "inline", :filename => "personal_certificate.crt")
  end
  
  def download_cert
    uniqueid = params[:id]
    crt = Certificate.find_by_certificate_request_uniqueid(uniqueid)
    if crt
      if crt.owner_type == "Person"
        send_data(crt.body, :type => "application/uknown", :disposition => "inline", :filename => "personal_certificate.pem")
      else
        send_data(crt.body, :type => "application/uknown", :disposition => "inline", :filename => X509Certificate::CertificateReader.new(crt.body).certificate[:SubjAltNames].sub("DNS:","") + ".pem")
      end
    else
      redirect_to :action => "search_crt"
    end
  end
  
  def get_personal_certificate
    @action_title = "#{I18n.t "controllers.cert.personal_cert"}"
    uniqueid = params[:id]
    @csr = CertificateRequest.find_by_uniqueid(uniqueid)
    @crt = Certificate.find_not_accepted_certificate_by_uniqueid(uniqueid)
  end
  
  def get_host_certificate
    @action_title = "#{I18n.t "controllers.cert.host_cert"}"
    uniqueid = params[:id]
    @csr = CertificateRequest.find_by_uniqueid(uniqueid)
    @crt = Certificate.find_not_accepted_certificate_by_uniqueid(uniqueid)
  end

  def test_browser_for_user_cert
    @action_title = "#{I18n.t "controllers.cert.cert_check_browser"}"
    if params[:id] && params[:id] == "new_window"
      render(:layout => "layout_cert_in_browser_test")
    end
  end
  
  def show_request_details
    @action_title = "#{I18n.t "controllers.cert.req_details"}"
    @req = CertificateRequest.find(params[:id])
    @ReqReader  = X509Certificate::RequestReader.new(@req.body)
  end
end
