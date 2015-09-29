json.array!(@assignments) do |assignment|
  json.extract! assignment, :id, :name
end
