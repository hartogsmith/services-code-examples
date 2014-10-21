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

if @nation && @basic_page_path && @page_author_id
  @counter = CSV.open(@basic_page_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@basic_page_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end

    name = row['title']
    page_slug = "#{row['slug']}_#{Time.now.month}_#{Time.now.day}_#{Time.now.year}_#{Time.now.hour}#{Time.now.min}"
    created_at = row['created_at'] rescue Time.now
    page_tags = row['page_tags'].gsub(/\s+/, "").split(',')
    live_page_to_import = row['external_url']
    excerpt = row['excerpt']
    external_id = row['external_id']

    content_html = Nokogiri::HTML(row['content_html'])
    local_target = FileUtils::mkdir_p("./images/#{page_slug}").first
    
    download_images_from_site(live_page_to_import, local_target)
    fix_image_path_from_file(content_html)

    # Set the body of the blog post
    basic_page_params = {
      site_slug: @site_slug, 
      basic_page: {
        name: name,
        slug: page_slug,
        status: 'published',
        content: content_html,
        tags: page_tags,
        published_at: created_at,
        external_id: external_id,
        author_id: @page_author_id
      }
    }

    api_call = create_basic_page(basic_page_params)
    puts "#{api_call.status} | #{api_call.reason}"

    Dir.foreach(local_target) do |filename|
      unless filename == '.' || filename == '..' || filename == '.DS_Store'
        encoded_image = encode_image(local_target, filename)
          api_call = upload_file(encoded_image, filename, @site_slug, page_slug)
        puts "#{api_call.status} | #{api_call.reason}"
      end
    end

    puts "Finished row ##{count} | page_slug is #{page_slug}"
  end
else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path} | page_author_id: #{@page_author_id}"
  puts "Required variabled can be found in config.rb"
end