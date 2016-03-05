class AddTweetIdToClues < ActiveRecord::Migration
  def change
    add_column :clues, :status_id, :string
  end
end
