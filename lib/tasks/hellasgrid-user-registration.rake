namespace :hg_administration do
  desc "Load data from YAML fixtures"
  task :load_data_from_yaml do
  [ 
     "UncheckedPerson", 
     "Certificate",
     "DistinguishedName",
     "AlternativeName",
     "Host",
     "Organization",
     "EmailConfirmation",
     "CertificateRequest",
     "RAStaffMembership",
     "RegistrationAuthority",
     "SeeVoRequest",
     "UiRequest"
   ].each do |table|
      `script/runner '#{table}.load_from_file' `
   end
  end
end