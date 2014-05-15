class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :handle
      t.integer :score

      t.timestamps
    end
  end
end
