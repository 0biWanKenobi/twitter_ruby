class GetFollowersAndFriendsNumberJob < Struct.new(:client, :name, :id)

  def perform
    @request = Twitter::REST::Request.new(client, 'get', '1.1/users/show.json', {:screen_name=>name})
    @info = @request.perform
    @account = Account.find(id)
    @account.update_attributes({:followers=>@info[:followers_count], :following=>@info[:friends_count]})     
  rescue Twitter::Error::TooManyRequests => error
    puts "Rate limit error, rescheduling after #{error.rate_limit.reset_in} seconds...".color(:yellow)
    @time_before_retry =  error.rate_limit.reset_in
  end

  def after (job)
    Pusher.trigger('create_user', 'success', {
      name: @account[:name],
      followers: @account[:followers],
      friends: @account[:following]
    })
  end

  def error(job, exception)
    @exception = exception
  end

  def reschedule_at(current_time, attempts)
    if at_rate_limit?
      @exception.rate_limit.reset_at
    else #default behaviour
      current_time + 5.seconds**attempts
    end
  end

  def queue_name
    'create_user'
  end

  private

  def at_rate_limit?
    @exception.is_a?(Twitter::Error::TooManyRequests)
  end
end