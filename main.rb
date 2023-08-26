require 'open-uri'
require 'nokogiri'
require 'yaml'

ScrapperMetadata = Struct.new(:site, :num_links, :images, :last_fetch)

class WebScraper

  @@metadata_hash = YAML.load_file('metadata.yml') || {}

  def self.scrap_url(url, url_name)
    html_data = URI.open(url).read
    #parse webpage
    html_parser = Nokogiri::HTML.fragment(html_data)
    images_count = html_parser.css('img').count
    links_count = html_parser.css('a').count
    curr_metadata = ScrapperMetadata.new(url, links_count, images_count, Time.now.utc.strftime("%a %b %d %Y %H:%M UTC"))
    return html_data, curr_metadata.to_h
  end

  def self.strip_url(url)
    url.strip.delete_prefix('https://')&.concat('.html')
  end

  def self.process_urls(urls)
    urls.each do |url|
      begin
        url_name = url.strip.delete_prefix('https://')&.concat('.html')
        html_data, curr_metadata =  scrap_url(url, url_name)
        #save file and metadata
        File.write(url_name, html_data)
        @@metadata_hash[url_name] = curr_metadata
        File.write('metadata.yml', @@metadata_hash.to_yaml)
      rescue Errno::ENOENT => e
        puts "Error while opening this url : ", url
      end
    end
  end

  def self.read_metadata(urls)
    urls.each do |url|
      url_name = strip_url(url)
      puts "\n"
      @@metadata_hash[url_name]&.keys&.each { |key| puts "#{key}: #{@@metadata_hash[url_name][key]} \n" } 
    end
  end
end

if(ARGV.length)
  if(ARGV[0] === '--metadata')
    puts 'show metadata'
    WebScraper.read_metadata(ARGV.drop(1))
  else
    WebScraper.process_urls(ARGV)
  end
end

