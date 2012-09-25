#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

begin
  doc = Nokogiri::HTML(open("http://www.openoffice.org/download/other.html",
	  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 1074) AppleWebKit/536.25 (KHTML like Gecko) Version/6.0 Safari/536.25") )
rescue
  puts "Failed to fetch download page"
  exit 1
end

doc.xpath('//a').each do |link|
  next if link['href'].match(/SDK/i)
  if link['href'].match(/MacOS_x86_install_en-US.dmg\/download/i)
      if ARGV.count >= 1
        File.open(ARGV[0], "w") do |file|
          file.puts link['href']
        end
      else
        puts link['href']
      end

      exit
  end
end
