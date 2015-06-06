# == Schema Information
#
# Table name: credentials
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  type       :string(32)       not null
#  name       :string(128)
#  updated_at :datetime         not null
#  key        :binary(2048)
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
