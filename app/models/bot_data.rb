# == Schema Information
#
# Table name: bot_data
#
#  id              :integer          not null, primary key
#  last_tweet_read :integer
#  num_players     :integer
#  winner          :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class BotData < ActiveRecord::Base
  validates :last_tweet_read, :presence => true

  def self.yesterdays_final_clue
    BotData.all.sort.last.last_tweet_read.to_i
  end

  def self.most_recent_clue
    Clue.where(:tweeted => true).order(:updated_at).last.status_id.to_i
  end
end
