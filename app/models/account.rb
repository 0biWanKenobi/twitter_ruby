class Account < ActiveRecord::Base
	validates :name, :followers, :following, presence: true
	validates :name, uniqueness: true
end
