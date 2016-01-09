class Account < ActiveRecord::Base
  # has_many :followers
  has_many :friends
	validates :name, presence: true
	validates :name, uniqueness: true

  def followers
    read_attribute(:followers_num) || 'fetching'
  end

  def friends
    read_attribute(:following) || 'fetching'
  end

  def update_stats
    @request = Twitter::REST::Request.new(@@client, 'get', '1.1/users/show.json', {:screen_name=>read_attribute(:name)} )
    @info = @request.perform
    update_attributes({:followers_num=>@info[:followers_count], :following=>@info[:friends_count]})  
  end


  def get_followers
    @loops = get_relation(Followers, 'followers', :follower, :followers_num)
  end

  def get_friends
    get_relation(Friends, 'friends', :friend, :following)
  end

  private


  def get_relation (model, breadcrumb, symbol, symbols)
    cursor = -1
    loops = 0
    batch_size = 200
    while true do
      @request = Twitter::REST::Request.new(@@client, 'get', '1.1/'+breadcrumb+'/list.json',  {:screen_name=>read_attribute(:name), :count=>batch_size, :skip_status=> true, :include_user_entities=>false, :cursor=>cursor})
      @relation = @request.perform

      cursor = @relation[:next_cursor]

      @relation = @relation[:users]
      @relation.each do |f|
        params = {:twitter_id=>read_attribute(:name), symbol=>f[:name]}
        model.new(params).save
        # if !model.where(params).any?
          
        # end
      end
      if cursor != 0
        loops+=1
        percentage = (batch_size*100*loops) / read_attribute(symbols)
        Pusher.trigger('load_'+breadcrumb, 'update', {percentage: percentage, cursor:loops, name:name, id: id})
      else 
        break
      end
    end
    return loops
  end

  @@client = Twitter::REST::Client.new do |config|
    #app auth allows for more requests every 15 minutes, possibly remove user key and secret
    config.consumer_key        = "bw6Ibw6DvDWZYTZJDgsIn12II"
    config.consumer_secret     = "lShJQA17tg93RVUCNhHRqAuHOOfSPvYqAJHihKbxT753GukKuJ"
    #config.access_token        = "4644992487-ZGV2FSbwYDCBgVyjMoAaoR3rXlUdnAwaCl9SYVE"
    #config.access_token_secret = "zbU5FfiibtontJiykO3ZInO4yzUDscByi9HjkOAGKy64G"
  end

end
