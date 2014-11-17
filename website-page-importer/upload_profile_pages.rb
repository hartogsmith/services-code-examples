require './nb.rb'
require './config.rb'

set_data_paths
connect_nation(@slug, @token)
count = 0

log = CSV.open("./files/log_#{@slug}_#{@offset}.csv", 'w')

if @nation && @profile_page_path
  @counter = CSV.open(@profile_page_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@profile_page_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end

    api_call = @nation.call(
                            :people,
                            :push,
                            person: {
                              email: row['email'].strip,
                              profile_content: row['profile_content'].to_s,
                              profile_headline: row['headline'].to_s,
                              # university is the slug of a (text) custom field
                              university: row['school'].to_s.strip
                            })

    if api_call
      log << [count, api_call.status, api_call.reason, api_call.body]
      puts "#{count} | #{api_call.status} | #{api_call.reason} | Email: #{row['email1']}"
    end
    count += 1
  end
  log.close
else
  puts "Script cannot be run - nation: #{@nation} | profile_page_path: #{@profile_page_path}"
  puts "Required variables can be found in config.rb"
end