const XCN_CRYPT_STRING_BASE64 = &h01
const XCN_CERT_NAME_STR_DISABLE_UTF8_DIR_STR_FLAG = &h100000
const XCN_NCRYPT_UI_PROTECT_KEY_FLAG = &h01
const XCN_NCRYPT_ALLOW_EXPORT_FLAG = &h01

dim PROV_RSA_FULL
dim OLD_XENROLL
dim NEW_XENROLL

PROV_RSA_FULL = 1
OLD_XENROLL   = 0
NEW_XENROLL   = 1

'Function to check if the browser is running Vista
Function isVista()
    if InStr(navigator.userAgent, "NT") >= 0 And CInt(Mid(navigator.userAgent, InStr(navigator.userAgent, "NT")+3, 1)) >=6 then
        isVista =  true
     else
        isVista =  false
     End if
End Function

'Function to get the Cryptographic Providers
Function enumCSP
    enumCSP = ""
    if isVista then
        enumCSP = enumCSPVista
    else
        call enumCSPOthers
    End if
End Function

'Function - Get CSP on Vista
Function enumCSPVista
    Dim cspInformations
    enumCSPVista = "" 'init to a empty string
    '0 is false
    base = 0 
    enhanced = 0
    count = 0

    'Get all csp informations
    Set cspInformations = g_objClassFactory.CreateObject("X509Enrollment.CCspInformations") 
    cspInformations.AddAvailableCsps()
    'Iterate to find all providers
    'Default is Base or Enhanced. Use Enchanced if it exists
    For i = 0 to cspInformations.count-1
        Set cspInformation = cspInformations.ItemByIndex(i)
        if IsObject(cspInformation) then
            if cspInformation.Name = "Microsoft Base Cryptographic Provider v1.0" then
                base = count
            End if
            if cspInformation.Name = "Microsoft Enhanced Cryptographic Provider v1.0" then
                enhanced = count
            End if
			set element = document.createElement("OPTION") 
			element.text = cspInformation.Name
			element.value = cspInformation.Name
			document.GetData.csp.add(element)
            count = count + 1
        End if
    Next
    
    enumCSPVista = "Microsoft Base Cryptographic Provider v1.0"
    If enhanced then
        enumCSPVista = "Microsoft Enhanced Cryptographic Provider v1.0"
		document.GetData.csp.selectedIndex = enhanced
	Else
		document.GetData.csp.selectedIndex = base
    End if   
End Function

'Get CSP on non-Vista
Sub enumCSPOthers
	'This code is taken directly from the openCA
    dim prov
    dim name
	dim element
	dim xenroll

	On Error Resume Next

	xenroll = getXEnroll

	prov=0
	document.GetData.csp.selectedIndex = 0

	do
		name = ""
		if xenroll = OLD_XENROLL then
			name = certHelperOld.enumProviders(prov,0)
		else
			name = certHelperNew.enumProviders(prov,0)
		end if
		if Len (name) = 0 then
			exit do
		else
			set element = document.createElement("OPTION") 
			element.text = name
			element.value = name
			document.GetData.csp.add(element) 
			prov = prov + 1
		end if
	loop

	document.GetData.elements[0].focus()
End Sub

Sub GenReq
    if isVista then
        call GenReqVista
    else
        call GenReqOthers
    End if
End Sub

'Generate the certificate in vista and submit the form
Sub GenReqVista
    On Error Resume Next
    Dim cspProvider
    Dim keyLength
    Dim keySpecValue
    Dim strDn
    Dim contextUser
    
    contextUser = 1 'For a user
    keySpecValue = 1 'Default Settings
    cspProvider = enumCSP 'Get a cryptographic provider
    keyLength = 1024 'Default Settings
    
       
    'get the DN From the form
    Set theForm = document.GetData
    strDn = "CN=" + theForm.commonName.value + ",OU=" + theForm.organizationalUnitName.value + ",O=" + theForm.organizationName.value + ",C=" + theForm.countryName.value
    
    'Set up the cryptographic provider
    Dim cspInformation
    Dim cspInformations

    Set cspInformation = g_objClassFactory.CreateObject("X509Enrollment.CCspInformation")
    cspInformation.InitializeFromName(cspProvider)
    if err.number <> 0 then
        MsgBox "Cannot create Cryptographic Provider Object. Please contact support@grid.auth.gr. Error 001"
        exit sub
    end if
    Set cspInformations = g_objClassFactory.CreateObject("X509Enrollment.CCspInformations") 
    cspInformations.Add(cspInformation)
    if err.number <> 0 then
       MsgBox "Cannot add Cryptographic provider. Please contact support@grid.auth.gr. Error 002"
       exit sub
    end if
    
    'Build Private key object
    Dim objPrivateKey
    Set objPrivateKey = g_objClassFactory.CreateObject("X509Enrollment.CX509PrivateKey")
    if err.number <> 0 then
       MsgBox "Cannot create Private Key object. Please contact support@grid.auth.gr. Error 003"
       exit sub
    end if
    
    objPrivateKey.CspInformations = cspInformations
    objPrivateKey.ProviderName = cspProvider
    
    'XCN_NCRYPT_UI_PROTECT_KEY_FLAG
    'A user interface is typically displayed to indicate that a process is attempting to use the key.
    objPrivateKey.KeyProtection = XCN_NCRYPT_UI_PROTECT_KEY_FLAG
    'XCN_NCRYPT_ALLOW_EXPORT_FLAG
    'The private key can be exported. 
    objPrivateKey.ExportPolicy = XCN_NCRYPT_ALLOW_EXPORT_FLAG
    objPrivateKey.Length = keyLength
    objPrivateKey.keySpec = keySpecValue
    
    if err.number <> 0 then
       MsgBox "Cannot set Private Key properties. Please contact support@grid.auth.gr. Error 004"
       exit sub
    end if
    
    Dim objRequest
    Set objRequest = g_objClassFactory.CreateObject("X509Enrollment.CX509CertificateRequestPkcs10")
    if err.number <> 0 then
        MsgBox "Cannot create Request object. Please contact support@grid.auth.gr. Error 005"
        exit sub
    end if
    'Initializes the certificate request by using an IX509PrivateKey object   
    call objRequest.InitializeFromPrivateKey(contextUser, objPrivateKey, "")
    if err.number <> 0 then
        MsgBox "Cannot initialize from private key object. Please contact support@grid.auth.gr. Error 006"
        exit sub
    end if
    
    'Do something with that long ID
    ' Dim extensionTemplate1
    ' Set extensionTemplate1 = g_objClassFactory.CreateObject("X509Enrollment.CX509ExtensionTemplateName")
    ' if err.number <> 0 then
    '     MsgBox "Cannot create Template object. Please contact support@grid.auth.gr. Error 007"
    '    exit sub
    ' end if 
   ' extensionTemplate1.InitializeEncode("1.3.6.1.4.1.311.2.1.21")
   ' if err.number <> 0 then
   '    MsgBox "Cannot initialize Template object. Please contact support@grid.auth.gr. Error 008"
   '     exit sub
   ' end if
    
    'Add the extension template to the Request
    'objRequest.X509Extensions.Add(extensionTemplate1)
    'if err.number <> 0 then
    '    MsgBox "Cannot add template to request object. Please contact support@grid.auth.gr. Error 009"
    '    exit sub
    'end if
    
    'Convert the DN(string) to a DistinguishedName Object
	'Dim objX500NameFlags
    'Set objX500NameFlags = g_objClassFactory.CreateObject("X509Enrollment.CX500DistinguishedName")
    Dim objDn
    Set objDn = g_objClassFactory.CreateObject("X509Enrollment.CX500DistinguishedName")
    if err.number <> 0 then
        MsgBox "Cannot create DN object. Please contact support@grid.auth.gr. Error 010" + Err.description
        exit sub
    end if
    'XCN_CERT_NAME_STR_DISABLE_UTF8_DIR_STR_FLAG 
    'Prevents forcing printable Unicode strings to be encoded by using UTF-8.
    Const XCN_CERT_NAME_STR_REVERSE_FLAG = &H2000000
	Const XCN_CERT_NAME_STR_SEMICOLON_FLAG = &H40000000
    call objDn.Encode(strDN, XCN_CERT_NAME_STR_REVERSE_FLAG)
	'dim ll
	'Set ll = g_obgClassFactory.CreateObject("X509Enrollment.CX500NameFlags")
	'MsgBox "--->" + CLng(XCN_CERT_NAME_STR_REVERSE_FLAG) + "<---"
    
    if err.number <> 0 then
        MsgBox "Cannot encode the DN String " + strDN + " into an object. Please contact support@grid.auth.gr. Error 011" + Err.description
        exit sub
    end if
    
    'Add the DN object to the request
    objRequest.Subject = objDn
       
    'Initialize the enrollement using the request we built
    Dim objEnroll
    Set objEnroll = g_objClassFactory.CreateObject("X509Enrollment.CX509Enrollment")
    if err.number <> 0 then
         MsgBox "Cannot create enrollment object. Please contact support@grid.auth.gr. Error 012"
        exit sub
    end if
    objEnroll.InitializeFromRequest(objRequest)
    if err.number <> 0 then
         MsgBox "Cannot initialize enrollment object from request object. Please contact support@grid.auth.gr. Error 013"
        exit sub
    end if
    
    'Phew, finally we can generate the request
    Dim pkcs10
    'XCN_CRYPT_STRING_BASE64 - The string is base64 encoded without beginning and ending certificate headers.
    pkcs10 = objEnroll.CreateRequest(XCN_CRYPT_STRING_BASE64)
    if err.number <> 0 then
         MsgBox "Cannot create a certificate request. Please contact support@grid.auth.gr. Error 014"
        exit sub
    end if
    
    'If there was an error lets display an error message
    if Len(pkcs10) = 0 then
        MsgBox("Certificate couldn't be generated. Please contact support@grid.auth.gr. Error 015")
        Exit Sub
    End if
    'Set the form element to store the request
    Dim request 'store the request here
    request = pkcs10  
    theForm.request.value = request
    theForm.newkey.value = theForm.request.value
    
    'Submit the request Form
    theForm.submit
End Sub

'Generate the request in non-vista and submit the form
Sub GenReqOthers    
    dim theForm 
	dim options
	dim index
	dim szName
	dim sz10
	dim xenroll

	On Error Resume Next
	set theForm = document.GetData

	xenroll = getXEnroll

	name = theForm.csp.options(document.GetData.csp.selectedIndex).value
	if Len(name) > 0 then
		if xenroll = OLD_XENROLL then
			certHelperOld.ProviderName=name
			'MsgBox ("The used Cryptographic Service Provider is " & certHelperOld.ProviderName)
		else
			certHelperNew.ProviderName=name
			'MsgBox ("The used Cryptographic Service Provider is " & certHelperNew.ProviderName)
		end if
	else
		if xenroll = OLD_XENROLL then
			certHelperOld.ProviderName=""
		else
			certHelperNew.ProviderName=""
		end if
		'MsgBox ("The used Cryptographic Service Provider is the default one.")
	end if

	csr = ""

	szName = theForm.dn.value

	'Msgbox ("DN is " & szName)

	if xenroll = OLD_XENROLL then
		certHelperOld.providerType = PROV_RSA_FULL
		certHelperOld.HashAlgorithm = "SHA1"
		certHelperOld.KeySpec = 1
		certHelperOld.GenKeyFlags = 134217731
		if theForm.bits.value =  512 then
			certHelperOld.GenKeyFlags = 33554435
		end if
		if theForm.bits.value =  1024 then
			certHelperOld.GenKeyFlags = 67108867
		end if
		if theForm.bits.value =  2048 then
			certHelperOld.GenKeyFlags = 134217731
		end if
		sz10 = certHelperOld.CreatePKCS10(szName, "1.3.6.1.4.1.311.2.1.21")
	else
		certHelperNew.providerType = PROV_RSA_FULL
		certHelperNew.HashAlgorithm = "SHA1"
		certHelperNew.KeySpec = 1
		certHelperNew.GenKeyFlags = 134217731
		if theForm.bits.value =  512 then
			certHelperNew.GenKeyFlags = 33554435
		end if
		if theForm.bits.value =  1024 then
			certHelperNew.GenKeyFlags = 67108867
		end if
		if theForm.bits.value =  2048 then
			certHelperNew.GenKeyFlags = 134217731
		end if
		sz10 = certHelperNew.CreatePKCS10(szName, "1.3.6.1.4.1.311.2.1.21")
	end if

	' certHelper.GenKeyFlags
	'                        0x0400     keylength (first 16 bit) => 1024
	'                        0x00000001 CRYPT_EXPORTABLE
	'                        0x00000002 CRYPT_USER_PROTECTED
	'                        0x04000003
	'                        0x0200     => this works for some export-restricted browsers (512 bit)
	'                        0x02000003
	'                        33554435

	if Len(sz10) = 0 then 
		if xenroll = OLD_XENROLL then
			certHelperOld.GenKeyFlags = 134217730
			if theForm.bits.value =  512 then
				certHelperOld.GenKeyFlags = 33554434
			end if
			if theForm.bits.value =  1024 then
				certHelperOld.GenKeyFlags = 67108866
			end if
			if theForm.bits.value =  2048 then
				certHelperOld.GenKeyFlags = 134217730
			end if
			sz10 = certHelperOld.CreatePKCS10(csr, "1.3.6.1.4.1.311.2.1.21")
		else
			certHelperNew.GenKeyFlags = 134217730
			if theForm.bits.value =  512 then
				certHelperNew.GenKeyFlags = 33554434
			end if
			if theForm.bits.value =  1024 then
				certHelperNew.GenKeyFlags = 67108866
			end if
			if theForm.bits.value =  2048 then
				certHelperNew.GenKeyFlags = 134217730
			end if
			sz10 = certHelperNew.CreatePKCS10(csr, "1.3.6.1.4.1.311.2.1.21")
		end if

		if Len(theForm.asn1.value) = 0 then 
			MsgBox ("The generation of the request failed") 
			Exit Sub
		end if

	end if 

	theForm.request.value = sz10
	'msgbox (theForm.request.value)

	msgbox ("The certificate service request was successfully generated.")

	theForm.submit 
End Sub

Function getXEnroll
	dim tester

	On Error Resume Next

	tester = certHelperOld.MyStoreName
	if Len (tester) > 0 then
		getXEnroll = OLD_XENROLL
		MsgBox ("You are using an old Internet Explorer with a security bug in XEnroll.dll (MS02-48).")
	else
		tester = certHelperNew.MyStoreName
		if Len (tester) > 0 then
			getXEnroll = NEW_XENROLL
			'MsgBox ("You are using patched Internet Explorer.")
		end if
	end if
End Function