json.array! @receipts do |receipt|
  json.amount receipt['amount']
  json.type receipt['type']
end
