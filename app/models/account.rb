class Account < ActiveRecord::Base
	validates :name, presence: true
	validates :name, uniqueness: true

  def followers
    read_attribute(:followers) || 'fetching'
  end

  def friends
    read_attribute(:following) || 'fetching'
  end
end
