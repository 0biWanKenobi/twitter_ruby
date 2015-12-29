class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.integer :followers
      t.integer :following

      t.timestamps
    end
  end
end
