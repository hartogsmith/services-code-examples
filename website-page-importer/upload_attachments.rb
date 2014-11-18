require './nb.rb'
require './config.rb'

set_data_paths
connect_nation(@slug, @token)
count = 0

log = CSV.open("./files/log_#{@slug}_#{@offset}.csv", 'w')

begin
  @counter = CSV.open(@file_attachments_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@file_attachments_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end

    page_slug = row['slug'].to_s.strip

    additional_attachment = row['link']
    local_target = FileUtils::mkdir_p("./images/#{page_slug}_#{count}").first

    download_single_image_from_url(additional_attachment, local_target)

    Dir.foreach(local_target) do |filename|
      unless filename == '.' || filename == '..' || filename == '.DS_Store'
        encoded_file = encode_file(local_target, filename)
        api_call = upload_file(encoded_file, filename, @site_slug, page_slug)
        log << [count, api_call.status, filename, api_call.body] if api_call
        puts "#{count} | #{api_call.status} | #{api_call.reason} | #{page_slug}"
      end
    end

    count += 1
  end
  log.close
rescue => e
  puts "There was an error: #{e}"
end