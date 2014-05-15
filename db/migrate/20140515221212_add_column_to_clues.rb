class AddColumnToClues < ActiveRecord::Migration
  def change
    add_column :clues, :tweeted, :boolean, :default => false
  end
end
