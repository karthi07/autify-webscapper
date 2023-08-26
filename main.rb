require 'open-uri'

ARGV.each do |url|
  begin
    File.write(url.strip.delete_prefix('https://')&.concat('.html'), URI.open(url).read)
  rescue Errno::ENOENT => e
    puts "Error while opening this url : ", url
  end
end 
