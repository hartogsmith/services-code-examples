require 'nationbuilder'

def connect_nation(slug, token)
  @nation = NationBuilder::Client.new(slug, token)
end

def download_images_from_site(live_page, local_target)
  begin
    downloader = ImageDownloader::Process.new(live_page,local_target)
    downloader.parse(:any_looks_like_image => true)
    downloader.download()
  rescue => e
    puts "Link is broken, no images downloaded"
  end
end

def fix_image_path_from_file(field)
  field.css('img').each do |img|
    img['src'] = img['src'].split('/').last
  end
end

def create_blog_page(body)
  @nation.call(
    :blogs,
    :create,
    body)
end

def create_calendar_page(body)
  @nation.call(
    :calendars,
    :create,
    body)
end

def create_event_page(body)
  @nation.call(
    :events,
    :create,
    body)
end

def create_blog_post_page(body)
  @nation.call(
    :blog_posts,
    :create,
    body)
end

def create_basic_page(body)
  @nation.call(
    :basic_pages,
    :create,
    body)
end

def upload_file(encoded_image, filename, site_slug, page_slug)
  @nation.call(
    :page_attachments,
    :create,
    {
      site_slug: site_slug,
      page_slug: page_slug,
      attachment: {
        filename: filename,
        content_type: 'image/jpeg',
        updated_at: Time.now,
        content: encoded_image
      }
    })
end

def encode_image(local_target, file)
  File.open("#{local_target}/#{file}", 'r') do |image_file|  
    Base64.encode64(image_file.read).gsub(/\s+/, "")
  end
end