json.array! @assignments do |assignment|
  json.name assignment.name
  json.stated_deadline assignment.due_at
  json.due_at assignment.due_at_for(current_user)

  json.deliverables assignment.deliverables do |deliverable|
    json.id deliverable.id.to_s
    json.name deliverable.name
  end

  json.metrics assignment.metrics do |metric|
    next unless metric.can_read? current_user
    json.name metric.name
    json.max_score metric.max_score
    json.weight metric.weight.to_f
  end
end
