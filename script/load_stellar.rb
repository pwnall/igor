#!/usr/bin/env ruby

unless ARGV[0]
  puts "Usage: #{$0} [stellar_email_file]"
  exit 1
end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

doc = Nokogiri.HTML File.read(ARGV[0])
users = Hash[doc.css('table tbody tr.recipient.participantRole').map do |tr|
  cells = tr.css('td').map(&:inner_text)
  name, email = *cells
  name = $2 + ' ' + $1 if /(.+), (.+)/ =~ name
  [name, email]
end]

course = Course.main

users.each do |name, email|
  user = User.create :email => email,  :password => email.reverse,
                     :password_confirmation => email.reverse
  user.active = true
  user.save!

  first_name = name.split(' ', 2).first
  Profile.create! :user => user, :name => name,
      :nickname => first_name, :university => 'MIT', :allows_publishing => true,
      :department => 'Electrical Eng & Computer Sci', :year => 1.to_s,
      :athena_username => email.split('@', 2).first,
      :about_me => "Imported from Stellar"

  registration = Registration.create! :user => user, :course => course,
      :dropped => false, :for_credit => true  
end
