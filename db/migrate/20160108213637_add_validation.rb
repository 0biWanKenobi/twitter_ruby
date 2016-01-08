class AddValidation < ActiveRecord::Migration
  def self.up
    add_column :accounts, :valid , :boolean , :default => false
  end

  def self.down
  end
end
