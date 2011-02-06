#!/usr/bin/env ruby

# stock samples are temp saved to ~/Documents/UCreateMusic/Loop
# your samples go in ~/Documents/UCreateMusic/Samples/queue by default
# requires `gem install rb-fsevent`
#
# just `ruby loader.rb` to start monitoring the Loop dir
# then go through the dumb flash site and save whatever to the device
# this script will detect as the stock files are loaded and replace them
#

STOCK_SAMPLES_DIR = File.expand_path(File.dirname(__FILE__)+'/Loop') # where the flash site will be saving its files
CUSTOM_SAMPLES_DIR = File.expand_path(File.dirname(__FILE__)+'/Samples/queue') # samples we want to load, can be named anything, loads them alphabetically

puts "STOCK_SAMPLES_DIR: #{STOCK_SAMPLES_DIR}"
puts "CUSTOM_SAMPLES_DIR: #{CUSTOM_SAMPLES_DIR}"

require 'fileutils'
require 'rubygems'
require 'rb-fsevent'

# bahleted!
Dir.chdir(STOCK_SAMPLES_DIR)
Dir['*.lop'].each do |stock|
  unless File.directory? stock
    puts "deleting: #{stock}"
    File.delete stock
  end
end

Dir.chdir(STOCK_SAMPLES_DIR)
existing = Dir['*.lop']
Dir.chdir(CUSTOM_SAMPLES_DIR)
queue = Dir['*.*']

if queue.any?
  puts "queue: #{queue.inspect}"
  fsevent = FSEvent.new
  fsevent.watch STOCK_SAMPLES_DIR do |dirs|  
    dir = dirs.first # only teh first
    Dir.chdir(dir)
    news = Dir['*'] - existing
    puts "new files: #{news.inspect}"
    news.each do |replace|
      replacer = queue.shift
      if replacer && replace
        puts "replacing #{replace} with #{replacer}"
        existing << replace
        FileUtils.cp(
          CUSTOM_SAMPLES_DIR+"/"+replacer,
          STOCK_SAMPLES_DIR+"/"+replace
          )
      end
    end
    if queue.empty?
      puts "queue empty"
      fsevent.stop
    end
  end
  fsevent.run
else
  puts "no files in queue"
end

