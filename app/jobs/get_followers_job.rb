class GetFollowersJob < Struct.new(:client, :name, :cursor)

  def perform
    @request = Twitter::REST::Request.new(client, 'get', '1.1/followers/list.json',  {:screen_name=>name, :count=>200, :skip_status=> true, :include_user_entities=>false, :cursor=>cursor})
    @followers = @request.perform
    @previous = @followers[:previous_cursor] > 0 ? @followers[:previous_cursor] : -1
    @next = @followers[:next_cursor]
    @followers = @followers[:users]
    #https://www.youtube.com/watch?v=eO8tTPDEB8A memcached
   
  end

  def after (job)
    Rails.cache.fetch (job.id) {@followers}
  end

end