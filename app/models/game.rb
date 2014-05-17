# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  game_id    :integer
#  scraped    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Game < ActiveRecord::Base
  validates :game_id, :presence => true, :uniqueness => true
end
