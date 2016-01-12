class Account < ActiveRecord::Base
  has_many :followers, dependent: :destroy
  has_many :friends, dependent: :destroy
	validates :name, presence: true
	validates :name, uniqueness: true


  def update_stats
    @info = @@client.user(name)
    update_attributes({twitter_id: @info.id, followers_num: @info.followers_count, following: @info.friends_count})  
  end


  def get_followers
    params = {:skip_status=> true, :include_user_entities=>false}
    @cursor = @@client.followers(twitter_id, params)
    count = 0
    loops = 0
    @cursor.each do |f|
      self.followers.new(follower: f.name).save
      count+=1
      if count == 200
        count = 0
        loops+=1
        percentage = (200*100*loops) / followers_num
        Pusher.trigger('load_followers', 'update', {percentage: percentage, cursor:loops, name:name, id: id})
      end
    end 
    return loops
  end

  def get_friends
    params = {:skip_status=> true, :include_user_entities=>false}
    @cursor = @@client.friends(twitter_id, params)
    count = 0
    loops = 0
    @cursor.each do |f|
      self.friends.new(friend: f.name).save
      count+=1
      if count == 200
        count = 0
        loops+=1
        percentage = (200*100*loops) / following
        Pusher.trigger('load_friends', 'update', {percentage: percentage, cursor:loops, name:name, id: id})
      end
    end 
    return loops
  end

  private

  @@client = Twitter::REST::Client.new do |config|
    #app auth allows for more requests every 15 minutes, possibly remove user key and secret
    config.consumer_key        = "bw6Ibw6DvDWZYTZJDgsIn12II"
    config.consumer_secret     = "lShJQA17tg93RVUCNhHRqAuHOOfSPvYqAJHihKbxT753GukKuJ"
    #config.access_token        = "4644992487-ZGV2FSbwYDCBgVyjMoAaoR3rXlUdnAwaCl9SYVE"
    #config.access_token_secret = "zbU5FfiibtontJiykO3ZInO4yzUDscByi9HjkOAGKy64G"
  end

end
