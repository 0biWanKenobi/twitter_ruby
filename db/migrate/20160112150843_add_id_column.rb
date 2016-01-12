class AddIdColumn < ActiveRecord::Migration
  def self.up
    add_column :accounts, :twitter_id , :integer , :default => 0
  end

  def self.down
  end
end