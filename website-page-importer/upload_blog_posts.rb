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

if @nation && @basic_page_path && @page_author_id
  @counter = CSV.open(@blog_post_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@blog_post_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end
  	
    name = row['title']
    page_slug = "#{row['slug']}_#{Time.now.month}_#{Time.now.day}_#{Time.now.year}_#{Time.now.hour}#{Time.now.min}"
    created_at = row['created_at'] rescue Time.now
    page_tags = row['page_tags'].to_s.split(',')
    live_page_to_import = row['external_url']
    external_id = row['external_id']

    content_html = Nokogiri::HTML(row['content_html'])
    content_flip_html = Nokogiri::HTML(row['content_flip_html'])
    
    local_target = FileUtils::mkdir_p("./images/#{page_slug}").first
    
    download_images_from_site(live_page_to_import, local_target)

    fix_image_path_from_file(content_html)
    fix_image_path_from_file(content_flip_html)

    # Set the body of the blog post
    blog_post_params = {
      site_slug: @site_slug,
      blog_id: @blog_id, 
      blog_post: {
        name: name,
        slug: page_slug,
        status: 'published',
        content_before_flip: content_html,
        content_after_flip: content_flip_html,
        tags: page_tags,
        published_at: created_at,
        external_id: external_id,
        author_id: @page_author_id
      }
    }

    api_call = create_blog_post_page(blog_post_params)
    log << "#{count}, #{api_call.status}, #{api_call.reason}, #{external_id}".split(',') if api_call
    puts "#{api_call.status} | #{api_call.reason}"

    if api_call
      Dir.foreach(local_target) do |filename|
        unless filename == '.' || filename == '..' || filename == '.DS_Store'
          encoded_image = encode_image(local_target, filename)
            api_call = upload_file(encoded_image, filename, @site_slug, page_slug)
          log << "#{count}, #{api_call.status}, #{page_slug}, #{live_page_to_import}".split(',') if api_call
          puts "#{api_call.status} | #{api_call.reason}"
        end
      end
    end

    count += 1
    puts "Finished row ##{count} | page_slug is #{page_slug}"
  end
else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path} | page_author_id: #{@page_author_id}"
  puts "Required variabled can be found in config.rb"
end