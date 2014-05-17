class CreateBotData < ActiveRecord::Migration
  def change
    create_table :bot_data do |t|
      t.string :last_tweet_read
      t.integer :num_players
      t.string :winner

      t.timestamps
    end
  end
end
