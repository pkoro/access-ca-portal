class RegisterController < ApplicationController
  include X509Certificate
  
  # First page/action
  def index
    render_comatose :page=>"home", :layout => true
  end
  
  def about_ca
      render :page=>"about_ca", :layout => true
  end
  
  # Show the person registration form
  # Pairnw tous organismous apo th db. H truncate
  # einai orismenh sto telos tou controller ws private.
  # Prosoxh prepei na einai energopoihmeno to UTF8 gia na 
  # gia na doulepsei h truncate
  def registration_form
    @action_title = "Φόρμα Εγγραφής Χρήστη"
    @organizations = Organization.find(:all,:order => "name_el ASC").map {|o| [truncate(o.name_el, 40), o.id]}
    @scientific_fields = ScientificField.find(:all).map {|o| [truncate(o.description, 40), o.id]}
  end
  
  # Pros8etei enan kainourgio xrhsth sthn database. An uparxei
  # error kanei render to action tou registration_form. Prepei
  # na ksanaparoume tous organismous!
  def add_new_person
    @action_title = "Φόρμα Εγγραφής Χρήστη"
    @person = Person.new(params[:person])
    if request.post? and @person.save
      record = @person
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Added Person with id = " + record.id.to_s,
                  :data => record.to_yaml)
      @person = Person.find_by_email(params[:person]['email'])
      email_confirmation_hash = Digest::SHA1::hexdigest @person.id.to_s
      record = EmailConfirmation.create(:user_hash => email_confirmation_hash, :person_id => @person.id)
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Added EmailConfirmation with id = " + record.id.to_s,
                  :data => record.to_yaml)
      confirmation_url = url_for :action => "confirm_email_address", :id => email_confirmation_hash
      rejection_url =  url_for :action => "reject_email_address", :id => email_confirmation_hash
      
      RegistrationMailer.deliver_confirmation_of_email_address(@person, email_confirmation_hash, confirmation_url, rejection_url )
      # email = RegistrationMailer.create_confirmation_of_email_address(@person, email_confirmation_hash, confirmation_url, rejection_url )
      # render(:text => "<pre>" + email.encoded + "</pre>")
      # redirect_to :action => "csr_form"
    else
      @organizations = Organization.find(:all).map {|o| [truncate(o.name_el, 40), o.id]}
      @scientific_fields = ScientificField.find(:all).map {|o| [truncate(o.description, 40), o.id]}
      render :action => "registration_form"
    end
  end
  
  # Action pou fortwnei to session enos xrhsth me bash to
  # email tou. Xrhsimo gia tous xrhstes pou exoun hdh parei
  # sto parel8on pistopoihtiko, alla den einai pleon eggyro. 
  def load_session
    if params[:person]
      @person = Person.find_by_email(params[:person]['email'])   
      if @person
        email_confirmation_hash = Digest::SHA1::hexdigest @person.id.to_s
        record = EmailConfirmation.create(:user_hash => email_confirmation_hash, :person_id => @person.id)
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Added EmailConfirmation with id = " + record.id.to_s,
                    :data => record.to_yaml)
        confirmation_url = url_for :action => "confirm_ownership_of_email_address", :id => email_confirmation_hash
        RegistrationMailer.deliver_confirm_ownership_of_email_address(@person, email_confirmation_hash, confirmation_url )
        # @confirmation_url = confirmation_url
        # session[:user_id] = @person.id
        # redirect_to :action => "csr_form"
      else
        redirect_to :action => "registration_form"
      end
    else
      redirect_to :action => "registration_form"
    end
  end
    
  def confirm_email_address
    email_confirmation_hash = params[:id]
    confirmation = EmailConfirmation.find_last_active_by_hash(email_confirmation_hash)
    if confirmation
      confirmation.confirmed_on = Time.now
      confirmation.save
      record = confirmation
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Confirmed email with id = " + record.id.to_s,
                  :data => record.to_yaml)
      person = Person.find(confirmation.person_id)
      session[:user_id] = person.id
      person.email_confirmation = 1
      person.save
      flash[:notice] = "Η διεύθυνση επικοινωνίας #{person.email} επιβεβαιώθηκε επιτυχώς"
      redirect_to :action => "csr_form"
    else
      redirect_to :action => "index"
    end
  end
  
  def confirm_ownership_of_email_address
    email_confirmation_hash = params[:id]
    confirmation = EmailConfirmation.find_last_active_by_hash(email_confirmation_hash)
    if confirmation
      confirmation.confirmed_on = Time.now
      confirmation.save
      record = confirmation
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Confirmed ownership of email with id = " + record.id.to_s,
                  :data => record.to_yaml)      
      person = Person.find(confirmation.person_id)
      session[:user_id] = person.id
      person.email_confirmation = 1
      person.save
      flash[:notice] = "Η διεύθυνση επικοινωνίας #{person.email} επιβεβαιώθηκε επιτυχώς"
      redirect_to :action => "csr_form"
    else
      redirect_to :action => "index"
    end
  end
  
  def reject_email_address
    @action_title = "Δήλωση λάθους e-mail διεύθυνσης"
    email_confirmation_hash = params[:id]
    confirmation = EmailConfirmation.find_by_user_hash(email_confirmation_hash)
    if confirmation and !confirmation.confirmed_on
      record = confirmation
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Rejected email address with id = " + record.id.to_s,
                  :data => record.to_yaml)
      confirmation.destroy
    else
      redirect_to :action => "index"
    end
  end
  
  # Selida epiloghs ths me8odou me thn opoia 8a upoblh8ei
  # to certificate_request
  def csr_form
    @action_title = "Επιλογή Μεθόδου Παραγωγής της Αιτήσεως Πιστοποιητικού"
    @gen_in_browser_confirmation = "ΠΡΟΣΟΧΗ: Ακολουθώντας τη διαδικασία αυτή το προσωπικό " +
                                    "σας κλειδί θα δημιουργηθεί ΕΝΤΟΣ του browser που " + 
                                    "χρησιμοποιείτε.\n\nΓια να παραλάβετε το ψηφιακό πιστοποιητικό " +
                                    "σας όταν υπογραφεί από την Αρχή Πιστοποίησης, θα πρέπει " +
                                    "να χρησιμοποιείσετε τον ΙΔΙΟ υπολογιστή και τον ΙΔΙΟ " +
                                    "browser."
    @cur_user = session[:user_id]
    if !@cur_user
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "missing_registration"
    end
  end
  
  # Forma gia submition etoimou CSR. An den bre8ei to session xrhsth
  # ton stelnei sthn arxikh forma tou registration
  def manual_csr
    @action_title = "Φόρμα Υπάρχουσας Αίτησης Πιστοποιητικού"
    @person = Person.find_by_id(session[:user_id])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end
  end
  
  # Forma gia submission apo Mozilla*. An den bre8ei to session xrhsth
  # ton stelnei sthn arxikh forma tou registration
  def mozilla_csr
    @action_title = "Φόρμα Αίτησης Πιστοποιητικού από Mozilla/*"
    @person = Person.find_by_id(session[:user_id])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end
  end
  
  # Forma gia submission apo IE. An den bre8ei to session xrhsth
  # ton stelnei sthn arxikh forma tou registration
  def iexplorer_csr
    @action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE"
    @person = Person.find_by_id(session[:user_id])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end
  end
  
  def iexplorer_vista_csr 
   	@action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE" 
    @person = Person.find_by_id(session[:user_id])
    if ! @person
      flash[:notice] = "Από ότι φαίνεται ΔΕΝ έχετε ολοκληρώσει τη διαδικασία εγγραφής σας. Σε περίπτωση που έχετε εγγραφεί στο παρελθόν παρακαλούμε εισάγετε την ηλεκτρονικής σας διεύθυνση (e-mail) στο πεδίο της φόρμας ώστε να ελέγξουμε την εγγραφής σας."  
      redirect_to :action => "registration_form"
    end     
  end
  
  # Pairnei ta dedomena apo etoimo CSR. To uniqueid
  # einai to SHA1 to xronou se sec.microsecond
  # Epixhs dhmiourgia kai apo8hkeysh sto CSR stelnei
  # sto csr_receipt, alliws kanei render thn action
  # manual_csr kai emfanizei ta la8h
  def submit_csr
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
    @person = Person.find_by_id(session[:user_id])
    csr = RequestReader.new(params[:certificate_request][:body])
    if csr.request[:Type] == "Person"
      @csr = CertificateRequest.new(params[:certificate_request])
      @csr.requestor = @person 
      @csr.status = "pending"
      @csr.csrtype = "classic"
      @csr.uniqueid = uniqueid
      @csr.owner = @person
      if @csr.save
        record = @csr
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Created CSR with id = " + record.id.to_s,
                    :data => record.to_yaml)
        
        #render :inline => "<pre>test<%= @csr.body %></pre>"
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
    if session and session[:user_id] and params and params[:countryName] and params[:organizationName] and params[:organizationalUnitName] and params[:commonName] and params[:SPKAC]
      @person = Person.find_by_id(session[:user_id])
    
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
      @csr.body << "SPKAC=" + spkac.gsub(/\r/, "").gsub(/\n/, "")
      @csr.status = "pending"
      @csr.csrtype = "spkac"
      @csr.uniqueid = uniqueid
      @csr.requestor_id = @person.id
      @csr.owner = @person
      # for debuging: (prepei na ginoun hash ola pou akolouthoun meta)
      # render :inline => "<pre><%= @csr.body %></pre>"
      # return
      if @csr.save
        record = @csr
        RegistrationLog.create( :date => DateTime.now,
                    :from => request.env['HTTP_X_FORWARDED_FOR'],
                    :person_id => session[:userid],
                    :person_dn => session[:usercert],
                    :action => "Added CSR with id = " + record.id.to_s,
                    :data => record.to_yaml)
        redirect_to :action => "csr_receipt"
      else
        render :action => "mozilla_csr"
      end
    else
      redirect_to :action => "mozilla_csr"
    end
  end
  
  # O IE exei paragei to CSR se PKCS#10 morfh
  # Epituxhs dhmiourgia kai apo8hkeysh sto CSR stelnei
  # sto csr_receipt, alliws kanei render to action
  # iexplorer_csr
  def submit_iexplorer_csr
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s
    @person = Person.find_by_id(session[:user_id])
    certificate_request = "-----BEGIN CERTIFICATE REQUEST-----\n"
    certificate_request << params[:MSREQ]
    certificate_request << "-----END CERTIFICATE REQUEST-----"
    @csr = CertificateRequest.new
    @csr.status = "pending"
    @csr.body = certificate_request
    @csr.csrtype = "classic_ie"
    @csr.uniqueid = uniqueid
    @csr.requestor_id = @person.id
    @csr.owner=@person
    # for debuging: (prepei na ginoun hash ola pou akolouthoun meta)
    #@ll = csr.body
    #render :inline => "<pre><%= debug(params) %></pre>"
    if @csr.save
      record = @csr
      RegistrationLog.create( :date => DateTime.now,
                  :from => request.env['HTTP_X_FORWARDED_FOR'],
                  :person_id => session[:userid],
                  :person_dn => session[:usercert],
                  :action => "Added CSR with id = " + record.id.to_s,
                  :data => record.to_yaml)
      
      redirect_to :action => "csr_receipt"
    else
      render :action => "iexplorer_csr"     
    end
  end
   
  def submit_iexplorer_vista_csr 
    @action_title = "Φόρμα Αίτησης Πιστοποιητικου από IE" 
    uniqueid = Digest::SHA1::hexdigest Time.now.to_f.to_s 
    @person = Person.find_by_id(session[:user_id]) 
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
                          :action => "Added CSR with id = " + record.id.to_s,
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
    if session[:user_id]
      @person = Person.find(session[:user_id])
      if @person.active_personal_csr
        ras = @person.active_personal_csr.organization.registration_authorities.find(:all,:conditions=>["ra_id != 1"])
        @csr_status_link = url_for(:controller => "cert", :action => "monitor_request", :id => @person.active_personal_csr.uniqueid)
        @csr_ra_link = url_for(:controller => "ra", :action => "show_request_details", :id => @person.active_personal_csr.id)
        @csr_ca_link = url_for(:controller => "ca", :action => "show_request_details", :id => @person.active_personal_csr.id)
        if ras.size == 0
          RegistrationMailer.deliver_notification_of_csr_submition_to_ca_no_ra(@person, @person.active_personal_csr,@csr_ca_link)
          RegistrationMailer.deliver_notification_of_csr_submition_to_user_no_ra(@person, @csr_status_link)
          render :action => "csr_receipt_no_ra"
        else
          @ra_info = ""
          ras.each {|o|
              @ra_info += o.description + ", " 
          }
          @ra_info = @ra_info.chop.chop
          RegistrationMailer.deliver_notification_of_csr_submition_to_ra(@person, @person.active_personal_csr,@csr_ra_link)
          RegistrationMailer.deliver_notification_of_csr_submition_to_user(@person, @csr_status_link)
        end

      else
        redirect_to :action => "csr_form"
      end
    else
      redirect_to :action => "registration_form"
    end
  end
    
  # Se diafores selides emfanizw to box pou leei oti prepei
  # na egkatasth8ei to hellasgrid ca certificate. To link gia
  # to ca certificate deixnei se auto edw to action. Molis ektelestei
  # orizei sto session oti exei perastei to ca certificate ston browser
  # kai sth sunexeia kanei redirect ton browser sto pistopoihtiko sto
  # pki.physics.auth.gr. Apo th stigmh pou oristei to installed_ca_cert
  # den 8a ksana emfanistei ston xrhsth to box
  def load_ca_cert
    session[:installed_ca_cert] = 1
    redirect_to "http://crl.grid.auth.gr/hellasgrid-ca-2006/cert/hellasgrid-ca-cert.crt"
  end
  
  # ka8arizei to session tou xrhsth
  def logout
     reset_session
     redirect_to :action => "index"
  end
  
  # debugging
  def test
    render_text request.env['HTTP_X_FORWARDED_FOR']
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
