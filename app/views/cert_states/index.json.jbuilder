json.array!(@cert_states) do |cert_state|
  json.extract! cert_state, :id, :name
  json.url cert_state_url(cert_state, format: :json)
end
