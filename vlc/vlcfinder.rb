#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("http://www.videolan.org/vlc/download-macosx.html"))

doc.xpath('//a').each do |link|
  if link.content.match(/Intel Mac/)
      puts link['href']
      exit
  end
end
