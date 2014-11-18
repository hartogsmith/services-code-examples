require './nb.rb'
require './config.rb'

set_data_paths
connect_nation(@slug, @token)
count = 0

log = CSV.open("./files/events_log_#{@site_slug}_#{@offset}.csv", "w")

if @nation && @event_page_path
  counter = CSV.open(@event_page_path, headers: true).count
  puts "Starting with #{counter} rows"

  CSV.foreach(@event_page_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end

    page_slug = row['page_slug'].strip
    content_html = Nokogiri::HTML(row['content_html'])    
    local_target = FileUtils::mkdir_p("./images/#{page_slug}").first 
    live_page_to_import = row['external_url']
    calendar_id = row['calendar_id']
    page_author = row['author_email']
    page_tags = row['page_tags'].split(',').each {|t| t.strip!}

    download_images_from_site(live_page_to_import, local_target)

    fix_image_path_from_file(content_html)

    # Find or creates the author by email from the csv
    if page_author
      author = find_or_create_signup_by_email(page_author)
      log << [count, author.status, author.reason, author.body]
      puts "#{author.status} | #{author.reason} | author_id #{JSON.parse(author.body)['person']['id']}"
      author_id = JSON.parse(author.body)['person']['id']
    else
      author_id = nil
    end

    event_page_params = {
      site_slug: @site_slug,
      calendar_id: calendar_id, 
      event: {
        name: row['title'],
        slug: page_slug,
        status: 'published',
        start_time: row['start_time'],
        end_time: row['end_time'],
        intro: content_html,
        tags: page_tags,
        published_at: Time.now,
        author_id: author_id,
        contact: {
          name: row['contact_name'],
          contact_phone: row['contact_phone'],
          show_phone: true,
          email: row['contact_email'],
          show_email: true
          },
        rsvp_form: {
          phone: 'optional',
          address: 'optional',
          allow_guests: true,
          accept_rsvps: true,
          gather_volunteers: false
          },
        venue: {
          name: row['venue'],
          address: {
            address1: row['address'],
            city: row['city'],
            state: row['state'],
            zip: row['zip']
          }
        }
      }
    }

    api_call = create_event_page(event_page_params)
    log << [count, api_call.status, api_call.reason, api_call.body] if api_call
    puts "#{api_call.status} | #{api_call.reason}"

    if api_call
      Dir.foreach(local_target) do |filename|
        unless filename == '.' || filename == '..' || filename == '.DS_Store'
          encoded_file = encode_file(local_target, filename)
          api_call = upload_file(encoded_file, filename, @site_slug, page_slug)
          log << [count, api_call.status, filename, api_call.body] if api_call
          puts "#{api_call.status} | #{api_call.reason}"
        end
      end
    end

    count += 1
    puts "Finished row ##{count} | page_slug is #{row['page_slug']}"
  end

  log.close

else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path}"
  puts "Required variables can be found in config.rb"
end