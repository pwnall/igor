# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_seven_session',
  :secret => '94bd254b7f53463d6ca00b39d12f62eb9a6287892cd6c2b4e1bc860d7b7b7abc65bb597579144fb84ed60e6405a16c9192e239588d96e718ccc0aba63aca033e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
