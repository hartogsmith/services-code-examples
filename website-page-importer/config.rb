# ======Guidelines======
#
# File assumes there are headers named 'title', 'slug', 'created_at', 'page_tags', 'external_url', 'author_email', 'external_id'
# For blog posts add 'content_html' and 'content_flip_html'
# For basic pages add 'content_html', 'excerpt'
# File must also use encoding 'utf-8'
#
# @slug is the slug of your nation
# @site_slug is the slug of the website of the nation to load data to
# @token is the api token that can be created at 'Settings' > 'Developer' > 'API Token'
# @_____page_path is the local path of the csv for the data to upload
# @offset = offset for the file in case script quits out during the import
#

def set_data_paths
  @slug = ''
  @site_slug = ''
  @token = ''
  @blog_post_path = './files/file.csv'
  @basic_page_path ='./files/file.csv'
  @event_page_path = './files/file.csv'
  @profile_page_path = './files/file.csv'
  @file_attachments_path = './files/file.csv'
  @calendar_id = 1
  @offset = 0
end