json.array!(@warehouses) do |warehouse|
  json.extract! warehouse, :name, :address, :zip, :city
  json.url warehouse_url(warehouse, format: :json)
end
