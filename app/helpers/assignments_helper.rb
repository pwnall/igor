module AssignmentsHelper
  def assignments_for(user)
    Assignment.includes(:deliverables).order('deadline DESC').select do |a|
      a.deliverables.any? { |deliverable| deliverable.visible_for? user }
    end
  end
end
