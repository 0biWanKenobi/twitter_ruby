class Followers < ActiveRecord::Base
  paginates_per 200
  validates_uniqueness_of :follower, scope: :twitter_id

  def self.get_by(name, page=1)
    Followers.where("twitter_id = '%s'", name).order(:follower).page(page)
  end
end
