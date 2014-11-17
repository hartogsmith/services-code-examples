# ======Guidelines======
#
# File assumes there are headers named 'title', 'slug', 'created_at', 'page_tags', 'external_url', 'author_email', 'external_id'
# For blog posts add 'content_html' and 'content_flip_html'
# For basic pages add 'content_html', 'excerpt'
# File must also use encoding 'utf-8'
#
# @site_slug is the slug for the nation
# @token is the api token that can be created at 'Settings' > 'Developer' > 'API Token'
# @blog_post_path and @basic_page_path are the paths where your csv(s) are located, by default it will be in the 'files' directory that is a part of this importer
# @blog_id is the id of the blog to add these posts to - you can list all blogs on your site using the API explorer (http://apiexplorer.nationbuilder.com/nationbuilder) or following instructions here: http://nationbuilder.com/blogs_api
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
  @calendar_id = 1
  @offset = 0
end