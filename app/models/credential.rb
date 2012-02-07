# == Schema Information
#
# Table name: credentials
#
#  id       :integer(4)      not null, primary key
#  user_id  :integer(4)      not null
#  type     :string(32)      not null
#  name     :string(128)
#  verified :boolean(1)      default(FALSE), not null
#  key      :binary
#

# Credential used to prove the identity of a user.
class Credential < ActiveRecord::Base
  include Authpwn::CredentialModel

  # Add your extensions to the Credential class here.
end

# namespace for all Credential subclasses
module Credentials

# Add your custom Credential types here.
  
end
