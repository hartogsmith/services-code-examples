require './nb.rb'
require './config.rb'

set_data_paths
connect_nation(@slug, @token)
count = 0

log = CSV.open("./files/basic_log_#{@site_slug}_#{@offset}.csv", "w")

if @nation && @basic_page_path
  @counter = CSV.open(@basic_page_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@basic_page_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end

    name = row['title']
    page_slug = row['page_slug'].strip
    created_at = row['created_at'] rescue Time.now
    page_tags = row['page_tags'].split(',').each {|t| t.strip!}
    live_page_to_import = row['external_url']
    excerpt = row['excerpt']
    external_id = row['external_id']
    page_author = row['page_author']
    headline = row['title']
    additional_attachment = row['attachment_url']

    content_html = Nokogiri::HTML(row['content_html'])
    local_target = FileUtils::mkdir_p("./images/#{page_slug}").first
    
    # Download files off live site(s)
    download_images_from_site(live_page_to_import, local_target)
    download_single_image_from_url(additional_attachment, local_target)

    fix_image_path_from_file(content_html)


    # Find or creates the author by email from the csv
    if page_author
      author = find_or_create_signup_by_email(page_author)
      log << [count, author.status, author.reason, author.body] if author
      puts "#{author.status} | #{author.reason} | author_id #{JSON.parse(author.body)['person']['id']}"
      author_id = JSON.parse(author.body)['person']['id']
    else
      author_id = nil
    end

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
        author_id: author_id,
        headline: headline
      }
    }

    api_call = create_basic_page(basic_page_params)
    log << [count, api_call.status, api_call.reason, api_call.body] if api_call
    puts "#{api_call.status} | #{api_call.reason}"

    Dir.foreach(local_target) do |filename|
      unless filename == '.' || filename == '..' || filename == '.DS_Store'
        encoded_image = encode_image(local_target, filename)
          api_call = upload_file(encoded_image, filename, @site_slug, page_slug)
          log << [count, api_call.status, api_call.reason, api_call.body] if api_call
        puts "#{api_call.status} | #{api_call.reason}"
      end
    end
    count += 1
    puts "Finished row ##{count} | page_slug is #{page_slug}"
  end

  log.close

else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path}"
  puts "Required variables can be found in config.rb"
end