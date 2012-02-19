# Security check.
#
# Example:
#     validates :homework, permission: { subject: grader, can: update }
# 
# This calls grader on the record being validated, then check for authorization
# by calling homework.can_update?(grader). If the method doesn't return a truthy
# result, the validation fails.
class PermissionValidator < ActiveModel::EachValidator
  def check_validity!
    permission = (options[:can] || :edit).to_sym
    @checker = :"can_#{permission}?"

    @subject = (options[:subject] || options[:with]).try(&:to_sym)
    raise ArgumentError, "Permissions options miss :subject" unless @subject
    
    @message = options[:message]
    @message ||= "cannot be #{permission}ed by #{@subject}"
  end
  
  def validate_each(record, attribute, value)
    subject = record.send @subject
    unless value && value.send(@checker, subject)
      record.errors[attribute] << @message
    end
    true
  end
end
