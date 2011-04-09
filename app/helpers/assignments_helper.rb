module AssignmentsHelper
  def visible_assignments(user)
    Assignment.includes(:deliverables).order_by(:deadline).select do |a|
      a.deliverables.any? { |deliverable| deliverable.visible_for_user? user }
    end
  end
end
