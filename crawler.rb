require 'singleton'
require 'logger'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

class Crawler
  include Singleton
  def initialize(logdev = STDOUT)
    @init_date = Time.now
    @start_date = nil
    @end_date = nil
    @url_prefix = "http://store.steampowered.com/search/?sort_by=Name&sort_order=ASC&category1=998&page="
    @page = 1
    @logger = Logger.new(logdev)
    @logger.debug(@init_date)
  end

  def start
    @start_date = Time.now
    @logger.info("[START] #{@start_date}")
    @game_count = 0
    1.times do |i|
      link = @url_prefix + (@page + i).to_s
      doc = Nokogiri.HTML(open(link), nil, 'utf-8')
      games = doc.search("a.search_result_row")
      games.each do |g|
        @game_count += 1
        original_price = nil
        name = g.at("div.search_name").at("h4").text
        price_node = g.at("div.search_price")

        if original_node = price_node.at("strike")
          price = price_node.text.sub(original_node.text + '$', '').to_f
          original_price = original_node.text.sub('$', '').to_f
        else
          price = price_node.text.sub('$', '').to_f
        end

        print name.to_s + "\n"
        print price.to_s
        if original_price
          print " (#{original_price})"
        end
        print "\n"

      end
    end

    @end_date = Time.now
    @logger.info("[END] #{@game_count} #{@end_date}")
  end
end
