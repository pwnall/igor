class CreateRobotUser < ActiveRecord::Migration
  def up
    user = User.new email: 'robot@localhost.edu',
        password: '_', password_confirmation: '_',
        profile_attributes: {
          name: 'Staff Robot', nickname: 'Robot',
          university: 'MIT', department: 'EECS', year: 'G',
          athena_username: '---',
          about_me: "Pay no attention to the man behind the curtain"
        }
    user.email_credential.verified = true
    user.admin = true
    user.save!
    user.password_credential.destroy
  end

  def down
    User.robot && User.robot.destroy
  end
end
