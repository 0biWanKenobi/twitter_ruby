class GetFollowersJob < Struct.new(:client, :name, :cursor)

  def perform
    @request = Twitter::REST::Request.new(client, 'get', '1.1/followers/list.json',  {:screen_name=>name, :count=>200, :skip_status=> true, :include_user_entities=>false, :cursor=>cursor})
    @followers = @request.perform
    @followers = @followers[:users]
    @followers.each do |f|
      Followers.new(name, f[:name])
    end
  end

  def after (job)
    Pusher.trigger('load_followers', 'success', { name: name })
  end

end