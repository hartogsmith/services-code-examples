# ======Guidelines======
#
# File assumes there are headers named 'title', 'slug', 'created_at', 'page_tags', 'external_url'
# For blog posts add 'content_html' and 'content_flip_html'
# For basic pages add 'content_html', 'excerpt'
# File must also use encoding 'utf-8'
#
# @site_slug is the slug for the nation
# @token is the api token that can be created at 'Settings' > 'Developer' > 'API Token'
# @blog_post_path and @basic_page_path are the paths where your csv(s) are located, by default it will be in the 'files' directory that is a part of this importer
# @blog_id is the id of the blog to add these posts to - you can list all blogs on your site using the API explorer (http://apiexplorer.nationbuilder.com/nationbuilder) or following instructions here: http://nationbuilder.com/blogs_api
# @page_author_id = NationBuilder ID of the page author
# @offset = offset for the file in case script quits out during the import
#

def set_data_paths
  @site_slug = ''
  @token = ''
  @blog_post_path = './files/gm_news_blog_posts_sample.csv'
  @blog_id = 1
  @basic_page_path ='./files/gm_news_blog_posts_sample.csv'
  @page_author_id = 1
  @offset = 0
end