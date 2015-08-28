json.array! @receipts do |receipt|
  json.amount receipt['amount']
  json.type receipt['type']
  json.receipt_id receipt['receipt_id']
  json.date receipt['date']
end
