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

if @nation && @blog_page_path && @page_author_id
  @counter = CSV.open(@blog_page_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@blog_page_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end
    
    name = row['title']
    page_slug = "#{row['slug']}_#{Time.now.month}_#{Time.now.day}_#{Time.now.year}_#{Time.now.hour}#{Time.now.min}"
    created_at = row['created_at'] rescue Time.now
    page_tags = row['page_tags'].to_s.split(',')
    external_id = row['external_id']

    # Set the body of the blog page
    blog_page_params = {
      site_slug: @site_slug,
      blog_id: @blog_id, 
      blog: {
        name: name,
        slug: page_slug,
        status: 'published',
        tags: page_tags,
        published_at: created_at,
        external_id: external_id,
        author_id: @page_author_id
      }
    }

    api_call = create_blog_post_page(blog_post_params)
    log << %w(count api_call.status api_call.reason external_id) if api_call
    puts "#{api_call.status} | #{api_call.reason}"

    count += 1
    puts "Finished row ##{count} | page_slug is #{page_slug}"
  end
else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path} | page_author_id: #{@page_author_id}"
  puts "Required variabled can be found in config.rb"
end