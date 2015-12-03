json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :name, :phone_number, :category_id
  json.url subscription_url(subscription, format: :json)
end
