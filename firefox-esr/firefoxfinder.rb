#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

stable_folder_url = ARGV[0]

doc = Nokogiri::HTML(open(stable_folder_url))

doc.xpath('//a').each do |link|
  if link.content.match(/Firefox.*\.dmg$/)
      puts stable_folder_url + "/" + link['href']
      exit
  end
end
