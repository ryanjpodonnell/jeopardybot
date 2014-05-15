class Clue < ActiveRecord::Base
  validates :text, :presence => true
  validates :answer, :presence => true
  validates :category, :presence => true
  validates :value, :presence => true
  validates :code, :presence => true, :uniqueness => true
end
