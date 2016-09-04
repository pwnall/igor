json.email @user.email
json.profile do
  json.name @user.profile.name
  json.nickname @user.profile.nickname
end
json.registrations @user.registrations do |registration|
  json.course registration.course.number
  json.for_credit registration.for_credit
end
json.roles @user.roles do |role|
  json.name role.name
  json.course role.course && role.course.number
end
