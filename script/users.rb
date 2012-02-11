# This script recovers profile information from server logs and the MIT directory.

require 'config/environment.rb'

log_text = File.read('log/production.log')

requests = log_text.split("\n\n").map!(&:strip)

requests = requests.select { |r| /^Started POST "\/users"/ =~ r } 

users_by_email = User.all.index_by(&:email)

requests.each do |r|
  params_line = r.lines.find { |l| /  Parameters: {/ =~ l }
  next unless params_line
  params_line = params_line[params_line.index('{')..-1]
  
  params_line.gsub! /"utf8"=>"."/, '"utf8"=>"?"'
  params_line.gsub! '=>', ':'
  params = JSON.parse params_line
  next unless params['user']
  em = params['user']['email']
  pi = params['user']['profile_attributes']
  next unless pi
  
  u = users_by_email[em]
  next unless u
  p = u.profile || Profile.new
  p.attributes = pi
  p.user = u
  p.save
end

include ProfilesHelper

User.all.each do |u|
  next if u.profile
  athena = u.email.split('@').first
  p = Profile.new :athena_username => athena
  m = MitStalker.from_user_name athena
  next if m.nil?
  p.name = m[:full_name]
  p.nickname = p.name.split(' ').first
  p.department = m[:department]
  p.department = 'NA' if p.department.blank?
  p.university = guess_university_from_athena(m)
  p.university = 'NA' if p.university.blank?
  p.year = m[:year] || '1'
  p.about_me = " "
  p.user = u
  p.save!
end
