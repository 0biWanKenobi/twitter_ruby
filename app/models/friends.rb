class Friends < ActiveRecord::Base
  paginates_per 200
  validates_uniqueness_of :friend, scope: :twitter_id

  def self.get_by(name, page=1)
    Friends.where("twitter_id = '%s'", name).order(:friend).page(page)
  end
end
