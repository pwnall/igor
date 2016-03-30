# Included by the models that receive submissions.
#
# The models currently are Assignment and Deliverable.
module Submittable
  def student_submissions
    student_ids = Set.new course.registrations.pluck :user_id

    submissions.select do |submission|
      subject = submission.subject
      if subject.kind_of? User
        next false unless student_ids.include?(subject.id)
      elsif subject.kind_of? Team
        team.members.each do |member|
          next false unless student_ids.include?(member.id)
        end
      else
        raise RuntimeError, "Unsupported subject type #{subject.class}"
      end
      true
    end
  end
end
