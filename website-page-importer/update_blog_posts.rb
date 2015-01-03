require './nb.rb'
require './config.rb'
# WIP: UPDATE TEXT ONLY, NOT CONCEREND WITH ATTACHMENTS FOR NOW
set_data_paths
connect_nation(@slug, @token)
count = 0

log = CSV.open("./files/posts_log_#{@site_slug}_#{@offset}.csv", "w")

if @nation && @update_blog_post_path
  @counter = CSV.open(@update_blog_post_path, headers: true).count
  puts "Starting with #{@counter} rows"

  CSV.foreach(@update_blog_post_path, headers: true) do |row|
    if count < @offset
      puts count if count % 10 == 0
      count += 1
      next
    end
# using csv based on api-returned data shaped like:
# id,content_before_flip,slug,path,status,site_slug,name,
# headline,title,excerpt,author_id,published_at,external_id,tags    

    blog_post_id = row['id'].to_i
    # content_before_flip function below
    page_slug = row['slug'].to_s
    live_page_to_import = row['path']
    page_status = row['status']
    # site_slug in config
    name = row['name'].to_s
    headline = row['headline'].to_s
    title = row['title'].to_s
    # excerpt function below
    author_id = row['author_id'].to_i
    published_at = row['published_at'] rescue Time.now
    external_id = row['external_id'].to_s
    page_tags = row['tags'].to_s.split(',').each {|t| t.strip!}
    blog_id = row['parent_id'].to_i

    content_html = Nokogiri::HTML(row['excerpt'])
    content_flip_html = Nokogiri::HTML(row['content_before_flip'])
    
    #local_target = FileUtils::mkdir_p("./images/#{page_slug}_#{count}").first
    
    #download_images_from_site(live_page_to_import, local_target)

    #fix_image_path_from_file(content_html)
    #fix_image_path_from_file(content_flip_html)

    # we are using valid author ids here, no need for this
    # Find the author by email from the csv
    # if page_author
    #  author = find_or_create_signup_by_email(page_author)
    #  log << [count, author.status, author.reason, author.body] if author
    #  puts "#{author.status} | #{author.reason} | author_id #{JSON.parse(author.body)['person']['id']}"
    #  author_id = JSON.parse(author.body)['person']['id']
    # else
    #  author_id = nil
    # end

    # Set the body of the blog post
    blog_post_params = {
      site_slug: @site_slug,
      blog_id: blog_id,
      blog_post_id: blog_post_id,
      blog_post: {
        name: name,
        headline: headline,
        title: title,
        slug: page_slug,
        status: page_status,
        content_before_flip: content_html,
        content_after_flip: content_flip_html,
        tags: page_tags,
        published_at: published_at,
        external_id: external_id,
        author_id: author_id
      }
    }
    puts "site_slug: #{@site_slug}, blog_id: #{blog_id}, blog_post_id: #{blog_post_id}"
    api_call = update_blog_post_page(blog_post_params)
    log << [count, api_call.status, api_call.reason, api_call.body] if api_call
    puts "#{api_call.status} | #{api_call.reason}"

    # do not need to use this?
    # if api_call
    #   Dir.foreach(local_target) do |filename|
    #     unless filename == '.' || filename == '..' || filename == '.DS_Store'
    #       encoded_file = encode_file(local_target, filename)
    #       api_call = upload_file(encoded_file, filename, @site_slug, page_slug)
    #       log << [count, api_call.status, filename, api_call.body] if api_call
    #       puts "#{api_call.status} | #{api_call.reason}"
    #     end
    #   end
    # end

    count += 1
    puts "Finished row ##{count} | page_slug is #{page_slug}"
  end

  log.close

else
  puts "Script cannot be run - nation: #{@nation} | basic_page_path: #{@basic_page_path}"
  puts "Required variables can be found in config.rb"
end
