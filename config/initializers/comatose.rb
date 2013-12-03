Comatose.configure do |config|
  config.admin_includes << :x509_login_helper
  config.admin_authorization = :login_required
  config.authorization = :login_required
  config.admin_get_author = Proc.new { session[:usercert] }
  config.admin_get_root_page = Proc.new { ComatosePage.find(1) }
  config.default_processor = :erb
  config.disable_caching = true
end