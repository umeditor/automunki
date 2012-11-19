#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

stable_folder_url = ARGV[0]

doc = Nokogiri::HTML(open("http://www.telestream.net/flip4mac/download.htm"))

doc.xpath('//a').each do |link|
    if link['href'].match(/http:\/\/download.microsoft.com\/download\//)
        puts link['href'].gsub(" ", "%20")
        exit
    end
end
