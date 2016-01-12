class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.string :twitter_id
      t.string :follower

      t.timestamps
    end
  end
end
