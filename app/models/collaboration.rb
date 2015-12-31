# == Schema Information
#
# Table name: collaborations
#
#  id              :integer          not null, primary key
#  submission_id   :integer          not null
#  collaborator_id :integer          not null
#

# The submission author's collaboration with another classmate.
class Collaboration < ActiveRecord::Base
  # The submission on which both students collaborated.
  belongs_to :submission, inverse_of: :collaborations
  validates :submission, presence: true

  # The classmate who collaborated on the submission.
  belongs_to :collaborator, class_name: :User
  validates :collaborator, presence: true, uniqueness: { scope: :submission }

  # The assignment on which the students collaborated.
  has_one :assignment, through: :submission

  # The course administering the assignment.
  has_one :course, through: :submission

  # The email address of the collaborator, if one exists.
  def collaborator_email
    collaborator && collaborator.email
  end
  # Reflect a failure to find the collaborator via email in :collaborator_email.
  def email_belongs_to_valid_user
    return unless collaborator
    if collaborator.new_record?
      errors.add :collaborator_email, 'is not a registered e-mail'
    elsif submission && !submission.can_collaborate?(collaborator)
      errors.add :collaborator_email,
          'does not belong to a student in this course'
    end
  end
  private :email_belongs_to_valid_user
  validate :email_belongs_to_valid_user

  # Set the collaborator to an existing user with the given email.
  #
  # If no user with the given email can be found, build a temporary user to
  # store the user-input email.
  #
  # @param [String] email the e-mail address used to find a collaborator
  def collaborator_email=(email)
    self.collaborator = User.with_email(email) || User.new(email: email)
  end
end
