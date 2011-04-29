# == Schema Information
# Schema version: 20110429122654
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

require 'spec_helper'

describe Token do
  fixtures :tokens, :users
  
  let(:email_token) do
    Token.new :action => 'confirm_email', :argument => nil    
  end
  
  it 'should validate the standard setup' do
    email_token.should be_valid    
  end
  
  it 'should validate when built off an account' do
    lambda {
      users(:admin).tokens.create :action => 'confirm_email'
    }.should change(Token, :count).by(1)
  end
end
