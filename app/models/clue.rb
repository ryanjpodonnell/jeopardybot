# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  text       :string(255)
#  answer     :string(255)
#  category   :string(255)
#  value      :integer
#  code       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  tweeted    :boolean          default(FALSE)
#

class Clue < ActiveRecord::Base
  validates :text, :presence => true
  validates :answer, :presence => true
  validates :category, :presence => true
  validates :value, :presence => true
  validates :code, :presence => true, :uniqueness => true
end
