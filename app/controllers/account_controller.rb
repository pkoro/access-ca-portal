# -*- coding: utf-8 -*-
class AccountController < ApplicationController
  include X509Certificate
  include SortHelper
  include X509LoginHelper
  helper :sort
  before_filter :get_user_dn
  before_filter :check_accepted_certificate, :except => [:accept_personal_certificate, :submit_certificate_acceptance]
	
  def index
	  @action_title = "Διαχείριση λογαριασμού"
  end
  
  def edit_personal_information
    @action_title = "Ενημέρωση προσωπικών στοιχείων"
    @organizations = Organization.find(:all,:order => "name_el ASC").map {|o| [truncate(o.name_el, 40), o.id]}
    @scientific_fields = ScientificField.find(:all).map {|o| [truncate(o.description, 40), o.id]}
    @person = Person.find_by_dn(session[:usercert])
  end
  
  def update_personal_information
    @action_title = "Ενημέρωση προσωπικών στοιχείων"
    @person = Person.find(session[:userid])

    if @person.update_attributes(params[:person])
      flash[:notice] = "Τα προσωπικά σας στοιχεία ενημερώθηκαν"
      record = @person
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Updated person with id = " + record.id.to_s,
                  :data => record.to_yaml)
      redirect_to :action => "index"
      #email_confirmation_hash = Digest::SHA1::hexdigest @person.id.to_s
      #EmailConfirmation.create  :hash => email_confirmation_hash, :person_id => @person.id
      #confirmation_url = url_for :action => "confirm_email_address", :id => email_confirmation_hash
      #rejection_url =  url_for :action => "reject_email_address", :id => email_confirmation_hash
      #RegistrationMailer.deliver_confirmation_of_email_address(@person, email_confirmation_hash, confirmation_url, rejection_url )
      # email = RegistrationMailer.create_confirmation_of_email_address(@person, email_confirmation_hash, confirmation_url, rejection_url )
      # render (:text => "<pre>" + email.encoded + "</pre>")
      # redirect_to :action => "csr_form"
    else
      @organizations = Organization.find(:all,:order => "name_el ASC").map {|o| [truncate(o.name_el, 40), o.id]}
      @scientific_fields = ScientificField.find(:all).map {|o| [truncate(o.description, 40), o.id]}
      render :action => "edit_personal_information"
    end
  end
  
  def csr_form
    @action_title = "Επιλογή Μεθόδου Παραγωγής της Αιτήσεως Πιστοποιητικού"
    @gen_in_browser_confirmation = "ΠΡΟΣΟΧΗ: Ακολουθώντας τη διαδικασία αυτή το προσωπικό " +
                                    "σας κλειδί θα δημιουργηθεί ΕΝΤΟΣ του browser που " + 
                                    "χρησιμοποιείτε.\n\nΓια να παραλάβετε το ψηφιακό πιστοποιητικό " +
                                    "σας όταν υπογραφεί από την Αρχή Πιστοποίησης, θα πρέπει " +
                                    "να χρησιμοποιείσετε τον ΙΔΙΟ υπολογιστή και τον ΙΔΙΟ " +
                                    "browser."
  end
  # Forma gia submition etoimou CSR. An den bre8ei to session xrhsth
  # ton stelnei sthn arxikh forma tou registration
  def manual_csr
    @action_title = "Φόρμα Υπάρχουσας Αίτησης Πιστοποιητικού"
    @person = Person.find_by_dn(session[:usercert])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end
  end
  
  # Forma gia submission apo Mozilla*. An den bre8ei to session xrhsth
  # ton stelnei sthn arxikh forma tou registration
  def mozilla_csr
    @action_title = "Φόρμα Αίτησης Πιστοποιητικού από Mozilla/*"
    @person = Person.find_by_dn(session[:usercert])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end
  end
  
  # Forma gia submission apo IE. An den bre8ei to session xrhsth
  # ton stelnei sthn arxikh forma tou registration
  def iexplorer_csr
    @action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE"
    @person = Person.find_by_dn(session[:usercert])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end
  end
  
  def iexplorer_vista_csr 
   	@action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE" 
    @person = Person.find_by_dn(session[:usercert])     
  end
  
  # Pairnei ta dedomena apo etoimo CSR. To uniqueid
  # einai to SHA1 to xronou se sec.microsecond
  # Epixhs dhmiourgia kai apo8hkeysh sto CSR stelnei
  # sto csr_receipt, alliws kanei render thn action
  # manual_csr kai emfanizei ta la8h
  def submit_csr
    @action_title = "Φόρμα Υπάρχουσας Αίτησης Πιστοποιητικού"
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
    @person = Person.find_by_dn(session[:usercert])
    csrReader = RequestReader.new(params[:certificate_request][:body])
    if csrReader.request[:Type] == "Person"    
      csr = CertificateRequest.new(params[:certificate_request])
      csr.status = "pending"
      csr.csrtype = "classic"
      csr.uniqueid = uniqueid
      csr.requestor = @person
      csr.owner = @person
      if csr.save
        record = csr
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Created csr with id = " + record.id.to_s,
                    :data => record.to_yaml)
        redirect_to :action => "csr_receipt"
      else
        render :action => "manual_csr"
      end
    else
      render :action => "manual_csr"
    end
  end
  
  # O Mozilla/* exei paragei to CSR se SPKAC morfh
  # Epituxhs dhmiourgia kai apo8hkeysh sto CSR stelnei
  # sto csr_receipt, alliws kanei render to action
  # mozilla_csr
  def submit_mozilla_csr
    @action_title = "Φόρμα Αίτησης Πιστοποιητικού από Mozilla/*"
    @person = Person.find_by_dn(session[:usercert])
    
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
    countryName = params[:countryName]
    organizationName = params[:organizationName]
    organizationalUnitName = params[:organizationalUnitName]
    commonName = params[:commonName]
    spkac = params[:SPKAC]
  
    @csr = CertificateRequest.new
    @csr.body = "C=" + countryName + "\n"
    @csr.body << "O=" + organizationName + "\n"
    @csr.body << "OU=" + organizationalUnitName + "\n"
    @csr.body << "CN=" + commonName + "\n"
    @csr.body << "SPKAC=" + spkac.gsub(/\r/, '').gsub(/\n/, '')
    @csr.status = "pending"
    @csr.csrtype = "spkac"
    @csr.uniqueid = uniqueid
    # for debuging: (prepei na ginoun hash ola pou akolouthoun meta)
    # @csr = csr
    # render :inline => "<pre><%= @csr.body %></pre>"
    @csr.requestor_id = @person.id
    @csr.owner = @person
    if @csr.save
      record = @csr
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Created csr with id = " + record.id.to_s,
                  :data => record.to_yaml)
      redirect_to :action => "csr_receipt"
    else
      render :action => "mozilla_csr"
    end
  end
  
  # O IE exei paragei to CSR se PKCS#10 morfh
  # Epituxhs dhmiourgia kai apo8hkeysh sto CSR stelnei
  # sto csr_receipt, alliws kanei render to action
  # iexplorer_csr
  def submit_iexplorer_csr
    @action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE"
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
    @person = Person.find_by_dn(session[:usercert])
    certificate_request = "-----BEGIN CERTIFICATE REQUEST-----\n"
    certificate_request << params[:MSREQ]
    certificate_request << "-----END CERTIFICATE REQUEST-----"
    csr = CertificateRequest.new
    csr.status = "pending"
    csr.body = certificate_request
    csr.csrtype = "classic_ie"
    csr.uniqueid = uniqueid
    csr.owner = @person
    csr.requestor_id = @person.id
    # for debuging: (prepei na ginoun hash ola pou akolouthoun meta)
    #@ll = csr.body
    #render :inline => "<pre><%= debug(params) %></pre>"
    if csr.save
      record = csr
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Created csr with id = " + record.id.to_s,
                  :data => record.to_yaml)      
      redirect_to :action => "csr_receipt"
    else
      render :action => "iexplorer_csr"     
    end
  end
  
  def submit_iexplorer_vista_csr 
    @action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE" 
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s 
    @person = Person.find_by_dn(session[:usercert]) 
    certificate_request = "-----BEGIN CERTIFICATE REQUEST-----\n" 
    certificate_request << params[:request] 
    certificate_request << "-----END CERTIFICATE REQUEST-----" 
    @csr = CertificateRequest.new 
    @csr.status = "pending" 
    @csr.body = certificate_request 
    @csr.csrtype = "vista_ie" 
    @csr.uniqueid = uniqueid 
    @csr.owner = @person 
    @csr.requestor_id = @person.id 
    if request.env['HTTP_X_FORWARDED_FOR'] 
      @remote_ip = request.env['HTTP_X_FORWARDED_FOR'] 
    elsif request.env['REMOTE_ADDR'] 
      @remote_ip = request.env['REMOTE_ADDR'] 
    end 
    if @csr.save 
      record = @csr 
      RegistrationLog.create( :date => DateTime.now, 
                          :from => @remote_ip, 
                          :person_id => session[:userid], 
                          :person_dn => session[:usercert], 
                          :action => "Created csr with id = " + record.id.to_s, 
                          :data => record.to_yaml)       
      redirect_to :action => "csr_receipt" 
    else 
      render :action => "iexplorer_vista_csr"      
    end 
  end
   
  # Ola ta epituxh certificate_requests prepei
  # na katalhksoun se auto to action. An ginei access
  # to action xwris na uparxei to session, tote ton
  # stelnei sthn arxikh selida tou registration
  def csr_receipt
    @action_title = "Στοιχεία Αίτησης Πιστοποιητικού"
    if session[:usercert]
      @person = Person.find_by_dn(session[:usercert])
      if !@person.active_personal_csr.nil?
        @csr_status_link = url_for(:controller => "cert", :action => "monitor_request", :id => @person.active_personal_csr.uniqueid)
        @csr_ra_link = url_for(:controller => "ra", :action => "show_request_details", :id => @person.active_personal_csr.id)
        @ra_info = ""
        @person.active_personal_csr.organization.registration_authorities.find(:all,:conditions=>["ra_id != 1"]).each {|o|
          @ra_info += o.description + ", " 
        }
        if @ra_info == ""
          @ra_info = RegistrationAuthority.find(1).description
        else
          @ra_info = @ra_info.chop.chop
        end
        if @person.last_id_check_on? && @person.last_id_check_on > 5.years.ago
          RegistrationMailer.deliver_notification_of_csr_renewal_to_ra(@person, @person.active_personal_csr,@csr_ra_link)
          RegistrationMailer.deliver_notification_of_csr_renewal_to_user(@person, @csr_status_link)
        else
          RegistrationMailer.deliver_notification_of_csr_submition_to_ra(@person, @person.active_personal_csr,@csr_ra_link)
          RegistrationMailer.deliver_notification_of_csr_submition_to_user(@person, @csr_status_link)
          render :action => "csr_receipt_with_id"
        end
      else
        redirect_to :action => "csr_form"
      end
    else
      redirect_to :controller => "register", :action => "registration_form"
    end
  end
  
  def ui_access_form
    @action_title = "Φόρμα Αίτησης Πρόσβασης σε UI"
  end
  
  def submit_ui_request
    @action_title = "Φόρμα Αίτησης Πρόσβασης σε UI"
    @person = Person.find_by_dn(session[:usercert])
    if (params[:ui_request]) && params[:ui_request][:accepted_aup] == "1"
      record = UiRequest.create :person_id => @person.id, :user_interface => params[:ui_request][:user_interface], :accepted_aup => params[:ui_request][:accepted_aup]
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Created UI request with id = " + record.id.to_s,
                  :data => record.to_yaml)
      RegistrationMailer.deliver_notification_of_ui_request(@person, params[:ui_request][:user_interface],"user-support@hellasgrid.gr")
      RegistrationMailer.deliver_notification_of_ui_request_to_user(@person)
      flash[:notice] = "Η αίτησή σας έχει αποσταλλεί στην ομάδα υποστήριξης του HellasGrid"
      redirect_to :action => "index"
    else
      flash[:notice] = "Πρέπει να αποδεχτείτε την πολιτική πρόσβασης και τους κανόνες χρήσης της υποδομής HellasGrid"
      redirect_to :action => "ui_access_form"
    end
    
  end
  
  def see_vo_form
    @action_title = "Φόρμα Αίτησης Πρόσβασης στο SEE VO"
  end

  def nwchem_vo_form
    @action_title = "Φόρμα Αίτησης Πρόσβασης στο nwchem VO"
  end

  def prace_t1_form
    @action_title = "Φόρμα Αίτησης Πρόσβασης στην υποδομή PRACE T1"
  end
  
  def submit_see_vo_request
    @action_title = "Φόρμα Αίτησης Πρόσβασης στο SEE VO"
    @person = Person.find_by_dn(session[:usercert])
    if (params[:see_vo_request]) && params[:see_vo_request][:accepted_aup] == "1"
      record = SeeVoRequest.create :person_id => @person.id, :accepted_aup => params[:see_vo_request][:accepted_aup]
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Created SEE VO request with id = " + record.id.to_s,
                  :data => record.to_yaml)
      RegistrationMailer.deliver_notification_of_see_vo_request(@person,"rt-vo-services@grid.auth.gr")
      flash[:notice] = "Η αίτησή σας έχει αποσταλλεί στην ομάδα υποστήριξης του SEE VO"
      redirect_to :action => "index"
    else
      flash[:notice] = "Πρέπει να αποδεχτείτε την πολιτική πρόσβασης και τους κανόνες χρήσης της υποδομής HellasGrid"
      redirect_to :action => "see_vo_form"
    end
  end
  
  def submit_nwchem_vo_request
    @action_title = "Φόρμα Αίτησης Πρόσβασης στο nwchem VO"
    @person = Person.find_by_dn(session[:usercert])
    if (params[:nwchem_vo_request]) && params[:nwchem_vo_request][:accepted_aup] == "1"
      record = NwchemVoRequest.create :person_id => @person.id, :accepted_aup => params[:nwchem_vo_request][:accepted_aup]
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Created nwchem VO request with id = " + record.id.to_s,
                  :data => record.to_yaml)
      RegistrationMailer.deliver_notification_of_nwchem_vo_request(@person,"rt-vo-services@grid.auth.gr")
      flash[:notice] = "Η αίτησή σας έχει αποσταλλεί στην ομάδα υποστήριξης του nwchem.vo.hellasgrid.gr VO"
      redirect_to :action => "index"
    else
      flash[:notice] = "Πρέπει να αποδεχτείτε την πολιτική πρόσβασης και τους κανόνες χρήσης της υποδομής HellasGrid"
      redirect_to :action => "nwchem_vo_form"
    end
  end
  
  def submit_prace_t1_request
    @action_title = "Φόρμα Αίτησης Πρόσβασης στην υποδομή PRACE T1"
    @person = Person.find_by_dn(session[:usercert])
    if (params[:prace_t1_request]) && params[:prace_t1_request][:accepted_aup] == "1"
      record = PraceT1Request.create :person_id => @person.id, :accepted_aup => params[:prace_t1_request][:accepted_aup]
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                 :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Created PRACE T1 request with id = " + record.id.to_s,
                  :data => record.to_yaml)
      RegistrationMailer.deliver_notification_of_prace_t1_request(@person,"iliaboti@admin.grnet.gr")
      flash[:notice] = "Η αίτησή σας έχει αποσταλλεί στην ομάδα υποστήριξης του PRACE T1"
      redirect_to :action => "index"
    else
      flash[:notice] = "Πρέπει να αποδεχτείτε την πολιτική πρόσβασης και τους κανόνες χρήσης της υποδομής PRACE T1"
      redirect_to :action => "prace_t1_form"
    end
  end

  def accept_personal_certificate
    @action_title = "Φόρμα Αποδοχής Προσωπικού Πιστοποιητικού"
    if params[:id]
      @person = Person.find_by_dn(session[:usercert])
      uniqueid = params[:id]
      @crt = Certificate.find_by_certificate_request_uniqueid(uniqueid)
    end
  end
  
  def accept_host_certificate
    @action_title = "Φόρμα Αποδοχής Πιστοποιητικού Διακομιστή"
    if params[:id]
      @person = Person.find_by_dn(session[:usercert])
      uniqueid = params[:id]
      @crt = Certificate.find_by_certificate_request_uniqueid(uniqueid)
    end
  end
  
  def submit_certificate_acceptance
    @action_title = "Φόρμα Αποδοχής Προσωπικού Πιστοποιητικού"  
    if params[:id]
      @uniqueid = params[:id]
      if params["accept_policy"]
        @crt = Certificate.find_by_certificate_request_uniqueid(@uniqueid)
        @crt.status = "valid"
        @crt.save
        record = @crt
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Accepted cert with id = " + record.id.to_s,
                    :data => record.to_yaml)
        flash[:notice] = "Το ψηφιακό σας πιστοποιητικό έχει ενεργοποιηθεί"
        redirect_to :controller => params[:redirected_from_controller], :action => params[:redirected_from_action]
      else
        flash[:notice] = "Αν δεν αποδεχθείτε τους όρους χρήσης του ψηφιακού σας πιστοποιητικού ΔΕΝ μπορείτε να το χρησιμοποιήσετε και θα ανακληθεί οριστικά εντός 7 ημερών από την ημέρα εκδόσεώς του."
        redirect_to :action => "accept_personal_certificate", :id => @uniqueid
      end
    else
      redirect_to :action => accept_personal_certificate
    end
  end

  def list_pending_csrs
    @action_title = "Λίστα αιτήσεων σε αναμονή"
    sort_init 'certificate_requests.id'
    sort_update
    @certificate_requests = CertificateRequest.paginate :page => params[:page], :per_page => 20, :order => sort_clause, :conditions => "requestor_id=" + Person.find_by_dn(session[:usercert]).id.to_s + " AND (status='pending' or status='approved')", :joins => "inner join organizations on certificate_requests.organization_id = organizations.id"
  end

  def logout
     reset_session
     redirect_to :action => "index"
  end
  
  def show_person_details
    @action_title = "Πληροφορίες χρήστη"
    @person = Person.find(params[:id])
  end
    
  private
    def truncate(text, length = 30, truncate_string = " ...")
      if text.nil? then return end
        l = length - truncate_string.length
      #if $KCODE == "NONE"
      #  text.length > length ? text[0...l] + truncate_string : text
      #else
        chars = text.split(//)
        chars.length > length ? chars[0...l].join + truncate_string : text
      #end
    end

    def word_wrap(text, line_width = 80)
      text.gsub(/\n/, "<br />\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    end
end
