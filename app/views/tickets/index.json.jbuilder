json.array!(@tickets) do |ticket|
  json.extract! ticket, :id, :property_id, :event_status, :customers_affected
  json.url ticket_url(ticket, format: :json)
end
