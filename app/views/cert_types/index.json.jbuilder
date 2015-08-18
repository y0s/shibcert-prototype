json.array!(@cert_types) do |cert_type|
  json.extract! cert_type, :id, :name
  json.url cert_type_url(cert_type, format: :json)
end
