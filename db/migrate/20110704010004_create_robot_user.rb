class CreateRobotUser < ActiveRecord::Migration
  def up
    user = User.new email: 'robot@localhost.edu',
                    password: '_', password_confirmation: '_'
    user.email_credential.verified = true
    user.admin = true
    user.save!
    user.password_credential.destroy
    
    profile = Profile.new name: 'Staff Robot', nickname: 'Robot',
        university: 'MIT', department: 'EECS', year: 'G',
        athena_username: '---',
        about_me: "Pay no attention to the man behind the curtain"
    profile.user = user
    profile.save!
  end

  def down
    User.robot && User.robot.destroy
  end
end
