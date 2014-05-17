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
end