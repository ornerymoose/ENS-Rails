json.array!(@properties) do |property|
  json.extract! property, :id, :name, :category_id
  json.url property_url(property, format: :json)
end
