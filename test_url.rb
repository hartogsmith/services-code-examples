require 'net/http'
require 'csv'

success = 0
failure = 0

count = CSV.open('redirect_links.csv', headers: true).count
csv = CSV.open('redirect_rates2.csv', 'w')
offset = 0

CSV.foreach('redirect_links.csv', headers: true) do |row|
  if count > offset
    puts count if count % 10 == 0
    count -= 1
    next
  end

  uri = row['path_with_domain']
  next unless uri

  url = URI.parse(uri)
  req = Net::HTTP.new(url.host, url.port)
  res = req.request_head(url.path)

  if res.code == "200"
    count -= 1
    success += 1
    csv << [row.to_hash.values, 'Success']
    puts count
  else
    count -= 1
    failure += 1
    csv << [row.to_hash.values, 'Failure']
    puts count
  end
end

csv.close
