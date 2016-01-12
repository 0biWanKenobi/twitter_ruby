class ChangeColumnNames < ActiveRecord::Migration
  def self.up
    rename_column :followers, :twitter_id, :account_id
    rename_column :friends, :twitter_id, :account_id
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
