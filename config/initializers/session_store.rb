# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_access_session',
  :secret      => '70420c203387fe9d7c3be4c3f7266e13358b97cb5ce70e3fd528d1285f16f131411406074ae8dfc114559deebe3903ab8fbc2ff04edc6ca0025ac0f4a3d7d88f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
