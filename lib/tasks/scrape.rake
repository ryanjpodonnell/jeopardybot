require 'open-uri'

namespace :scrape do
  desc "Scrape J-Archive Games"
  task games: :environment do        
    def scrape_round(page, round_name)
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
        c.value = values.first.text[1..-1].to_i

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
        
        tweet = c.category + ": " + c.text + " #" + c.code
        c.save if tweet.length <= 140
      end
    end
    
    games = Game.where(:scraped => false).map { |i| i.game_id }
    
    games.each do |game_id|
      page = Nokogiri::HTML(open('http://www.j-archive.com/showgame.php?game_id=' + game_id.to_s))
    
      ["jeopardy_round", "double_jeopardy_round"].each do |round_name|
        scrape_round(page, round_name)
      end
      
      game = Game.find_by(game_id: game_id)
      game.scraped = true
      game.save
    end
  end

end
