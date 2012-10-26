#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'

begin
  doc = Nokogiri::HTML(open("http://java.com/en/download/mac_download.jsp",
	  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 1074) AppleWebKit/536.25 (KHTML like Gecko) Version/6.0 Safari/536.25") )
rescue
  puts "Failed to fetch download page"
  exit 1
end

doc.xpath("//a").each do |link|
  if link['href'] && link['href'].match(/AutoDL\?BundleId/) && link.text.match("Download")
    puts link['href']
  end
end
