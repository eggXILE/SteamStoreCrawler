require 'logger'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

class Crawler
  PAGE_MAX = 100
  PREFIX   = "http://store.steampowered.com/search/?sort_by=Name&sort_order=ASC&category1=998&page="

  def initialize(logdev = STDOUT)
    @logger = Logger.new(logdev)
  end

  def start
    @logger.info("[START] Fetching...")
    start_time = Time.now
    game_count = fetch
    @logger.info("[ END ] Fetched #{game_count} games in #{Time.now - start_time} sec")
  end


  def fetch
    game_count = 0

    PAGE_MAX.times do |i|
      url = PREFIX + (i + 1).to_s
      doc = Nokogiri.HTML(open(url), nil, 'utf-8')

      games = doc.search("a.search_result_row")
      break if games.empty? # 検索結果の最終ページだったらbreak

      games.each do |g|
        game_count += 1
        original_price = nil # 後のif条件文にするためnilに初期化しておく
        name = g.at("div.search_name").at("h4").text
        price_node = g.at("div.search_price")

        if original_node = price_node.at("strike")
          price = price_node.text.sub(original_node.text + '$', '').to_f
          original_price = original_node.text.sub('$', '').to_f
        else
          price = price_node.text.sub('$', '').to_f
        end

        #
        # 出力 / DB操作
        #
        #################
        print name.to_s + "\n"
        print price.to_s
        if original_price
          print " (#{original_price})"
        end
        print "\n"

      end
    end
    return game_count
  end
end
