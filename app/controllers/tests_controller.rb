class Clue
  attr_accessor :text, :answer, :category, :value, :code
end

class TestsController < ApplicationController
  require 'nokogiri'
  require 'open-uri'
  
  def index 
    @clues = []
    
    def write_round(page, round_name)
      title = page.css("title")
      title.text =~ /Show #(\d+)/

      category_cells = page.css("div##{round_name} td.category_name")

      clue_tables = page.css("div##{round_name} td.clue>table")
      clue_tables.each do |clue_table|
        c = Clue.new

        # Populate the clue text
        clue_text_cell = clue_table.css("td.clue_text").first
        clue_id = clue_text_cell["id"]
        c.text = clue_text_cell.text

        # Populate the clue category
        clue_id =~ /^clue_([FD]?J)_(\d)_(\d)/
        category_num = $2.to_i - 1
        c.category = category_cells[category_num].text
        
        # Populate the clue value
        values = clue_table.css("td.clue_value")
        dd_values = clue_table.css("td.clue_value_daily_double")
        next if dd_values.length > 0
        c.value = values.first.text

        # Populate the clue answer
        clue_div = clue_table.css("div").first
        clue_div["onmouseover"] =~ /correct_response">(.*?)<\//
        answer = $1
        answer = answer.downcase
        answer.sub!(/^<i>/, "")
        answer.sub!(/^"/, "")
        answer.sub!(/"$/, "")
        c.answer = answer
        
        c.code = SecureRandom::urlsafe_base64(4)

        @clues.push(c)
        # puts c.category
        # puts c.text
        # puts c.answer
      end
    end
 
    page = Nokogiri::HTML(open('http://www.j-archive.com/showgame.php?game_id=4502'))
    
    ["jeopardy_round", "double_jeopardy_round"].each do |round_name|
      write_round(page, round_name)
    end
  
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end
end
