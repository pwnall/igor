#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

course = Course.main
[
  ['Yafim', 'landa@mit.edu'], ['Ying', 'yingyin@mit.edu'],
  ['Kevin', 'kelleyk@mit.edu'], ['Sarah', 'seisenst@mit.edu']
].each do |name, email|
  user = User.find_by_email email
  if user
    user.password = 'difficultxkcdpassword'
    user.password_confirmation = 'difficultxkcdpassword'
    user.active = true
    user.admin = true
    user.save!
    next
  end
  
  user = User.create :email => email,  :password => 'difficultxkcdpassword',
                     :password_confirmation => 'difficultxkcdpassword'
  user.active = true
  user.admin = true
  user.save!

  first_name = name.split(' ', 2).first
  Profile.create! :user => user, :name => name,
      :nickname => first_name, :university => 'MIT', :allows_publishing => true,
      :department => 'Electrical Eng & Computer Sci', :year => 'G',
      :athena_username => email.split('@', 2).first,
      :about_me => "Scripted"

  registration = Registration.create! :user => user, :course => course,
      :dropped => false, :for_credit => true, :motivation => "TA"  
end
