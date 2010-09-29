require 'spec_helper'

describe Token do
  fixtures :tokens, :users
  
  let(:email_token) do
    Token.new :action => 'confirm_email', :argument => nil    
  end
  
  it 'should validate the standard setup' do
    email_token be_valid    
  end
  
  it 'should validate when built off an account' do
    lambda {
      users(:admin).tokens.create :action => 'confirm_email'
    }.should change(Token, :count).by(1)
  end
end
