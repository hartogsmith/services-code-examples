require 'csv'
require 'nokogiri'

image_csv = CSV.open('slug_with_image.csv', 'w')

CSV.foreach('blog_file.csv', headers: true) do |row|
  content_html = Nokogiri::HTML(row['content'])
  content_html.css('img').each do |img|
    image_csv << [img['src'], row['slug']] 
  end
end

image_csv.close
