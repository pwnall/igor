# == Schema Information
# Schema version: 20110208012638
#
# Table name: tokens
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  token      :string(64)      not null
#  action     :string(32)      not null
#  argument   :string(1024)
#  created_at :datetime
#


# Random strings used for password-less authentication.
class Token < ActiveRecord::Base
  # Random hexadecimal string with the secret token.
  validates :token, :length => 1..64, :presence => :true, :uniqueness => :true
  
  # The TokenController method to be called when the token is spent.
  validates :action, :length => 1..32, :presence => true

  # An argument for the TokenController method called when the token is spent.
  serialize :argument

  # The user that the token is linked to.
  belongs_to :user, :inverse_of => :tokens

  # Generates a random string for the token.
  def generate_token
    self.token ||= Digest::SHA2.hexdigest OpenSSL::Random.random_bytes(32)
  end
  before_validation :generate_token
end
