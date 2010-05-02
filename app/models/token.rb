# == Schema Information
# Schema version: 20100502201753
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

require 'digest/sha2'

class Token < ActiveRecord::Base
  # The user that the token is linked to.
  belongs_to :user
  
  # Random hexadecimal string with the secret token.
  validates_length_of :token, :in => 1..64, :allow_nil => false
  validates_uniqueness_of :token
  
  # The TokenController method to be called when the token is spent.
  validates_length_of :action, :in => 1..32, :allow_nil => false

  # An argument for the TokenController method called when the token is spent.
  serialize :argument

  before_validation :generate_token
  
  # Generates a random string for the token.
  def generate_token
    self.token ||= Digest::SHA2.hexdigest OpenSSL::Random.random_bytes(32)
  end
end
