website-page-importer
======================

Uses the NationBuilder gem (nationbuilder-rb) and token authentication to import different page types into a nation from a CSV. 

You can also create a blog page or calendar page by passing the required parameters into the methods found in nb.rb

Example:

params = {
  site_slug: 'nationslug',
  blog: {
      status: 'published',
      name: 'My main blog',
      authod_id: 1
      }
  }

create_blog_page(params)

Required parameters can be found in NationBuilders API documentation here: http://nationbuilder.com/api_documentation
