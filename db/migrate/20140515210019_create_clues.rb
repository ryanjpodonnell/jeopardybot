class CreateClues < ActiveRecord::Migration
  def change
    create_table :clues do |t|
      t.string :text
      t.string :answer
      t.string :category
      t.integer :value
      t.string :code
      
      t.timestamps
    end
  end
end
