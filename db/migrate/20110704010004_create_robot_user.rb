class CreateRobotUser < ActiveRecord::Migration[4.2]
  def up
    robot = User.new email: 'robot@localhost.edu',
        password: '_', password_confirmation: '_',
        profile_attributes: {
          name: 'Staff Robot', nickname: 'Robot',
          university: 'MIT', department: 'EECS', year: 'G'
        }
    robot.email_credential.verified = true
    robot.save!
    robot.password_credential.destroy
    Role.create! user: robot, name: 'bot'
  end

  def down
    User.robot && User.robot.destroy
  end
end
