# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  handle     :string(255)
#  score      :integer
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  validates :handle, :presence => true, :uniqueness => true
  validates :score, :presence => true
end
