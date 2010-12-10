require File.join(File.dirname(File.expand_path(__FILE__)), 'crawler.rb')

log = open('log.txt', 'a')
c = Crawler.new(log)
c.start
log.close
