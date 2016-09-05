json.array! @submissions do |submission|
  json.deliverable_id submission.deliverable_id.to_s
  json.submitted_at submission.created_at.iso8601
  json.analysis do
    json.status submission.analysis.status
    json.scores submission.analysis.scores
  end
end
