#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("http://www.microsoft.com/mac/autoupdate/0409MSOf14.xml"))

updates = []

doc.xpath('//string').each do |link|
    if link.content.match(/.*.dmg/)
        next if link.content.match(/1410Update/);
        next if link.content.match(/1423Update/);  # The 14.2.3 update isn't a flat-pack
        updates << link.content
    end
end

updates.each do |update|
    system("./clean.sh")
    system("./build.sh", update)
end
