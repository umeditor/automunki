#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

stable_folder_url = ARGV[0]

doc = Nokogiri::HTML(open(stable_folder_url))

doc.xpath('//a').each do |link|
  if link['href'].match(/alfred_.*.dmg/)
      puts link['href']
      exit
  end
end
