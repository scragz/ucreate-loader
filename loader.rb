#!/usr/bin/env ruby

# this script goes in your ~/Documents/UCreateMusic dir
# samples go in ~/Documents/UCreateMusic/Samples/queue by default
# requires `gem install rb-fsevent`
#
# just `ruby loader.rb` to start monitoring the
#

STOCK_SAMPLES_DIR = File.expand_path(File.dirname(__FILE__)+'/Loop') # where the flash site will be saving its files
CUSTOM_SAMPLES_DIR = File.expand_path(File.dirname(__FILE__)+'/Samples/queue') # samples we want to load

puts "STOCK_SAMPLES_DIR: #{STOCK_SAMPLES_DIR}"
puts "CUSTOM_SAMPLES_DIR: #{CUSTOM_SAMPLES_DIR}"

require 'fileutils'
require 'rubygems'
require 'rb-fsevent'

# bahleted!
Dir.chdir(STOCK_SAMPLES_DIR)
Dir['*.lop'].each do |stock|
  puts "deleting #{stock}"
  File.delete stock unless File.directory? stock
end

Dir.chdir(STOCK_SAMPLES_DIR)
existing = Dir['*']
Dir.chdir(CUSTOM_SAMPLES_DIR)
queue = Dir['*.wav']

fsevent = FSEvent.new
fsevent.watch STOCK_SAMPLES_DIR do |dirs|
  dir = dirs.first # only teh first
  Dir.chdir(dir)
  new = Dir['*'] - existing
  puts "new files: #{new.inspect}"
  new.each do |replace|
    replacer = queue.shift
    if replacer && replace
      puts "replacing #{replace} with #{replacer}"
      existing << replace
      FileUtils.cp \
        CUSTOM_SAMPLES_DIR+"/"+(replacer),
        STOCK_SAMPLES_DIR+"/"+replace
    end
  end
end
fsevent.run

