#!/usr/bin/env ruby-2.1.0

require 'nationbuilder'
require 'pp'
require 'csv'
require 'nokogiri'
require 'image_downloader'
require 'fileutils'
require 'base64'
require './nb.rb'
require './config.rb'

set_data_paths
connect_nation(@site_slug, @token)
count = 0

log = CSV.open('./files/log.csv', 'w')

if @nation && @event_page_path && @page_author_id
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

    
    download_images_from_site(live_page_to_import, local_target)

    fix_image_path_from_file(content_html)

    event_page_params = {
      site_slug: @site_slug,
      calendar_id: @calendar_id, 
      event: {
        name: row['title'],
        slug: page_slug,
        status: 'published',
        start_time: row['start_time'],
        end_time: row['end_time'],
        intro: content_html,
        tags: row['page_tags'].gsub(/\s+/, "").split(','),
        published_at: Time.now,
        author_id: @page_author_id,
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
    log << %w(count api_call.status api_call.reason external_id) if api_call
    puts "#{api_call.status} | #{api_call.reason}"

    if api_call
      Dir.foreach(local_target) do |filename|
        unless filename == '.' || filename == '..' || filename == '.DS_Store'
          encoded_image = encode_image(local_target, filename)
            api_call = upload_file(encoded_image, filename, @site_slug, page_slug)
          log << %w(count, api_call.status, page_slug, live_page_to_import) if api_call
          puts "#{api_call.status} | #{api_call.reason}"
        end
      end
    end

    count += 1
    puts "Finished row ##{count} | page_slug is #{row['page_slug']}"
  end
else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path} | page_author_id: #{@page_author_id}"
  puts "Required variabled can be found in config.rb"
end