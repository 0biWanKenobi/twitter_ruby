class GetFollowersAndFriendsNumberJob < Struct.new(:account)

  def perform
    account.update_stats
    @success = true
  rescue Twitter::Error::NotFound => e
    @success = false
    Pusher.trigger('create_user', 'not_found',{name: account[:name]})
    account.destroy
    puts "exception rescued"
    
  end

  def success (job)
    if @success
      account.is_valid = true
      account.save
      Pusher.trigger('create_user', 'success', {
        name: account[:name],
        followers: account[:followers_num],
        friends: account[:following]
      })
    end
  end

  def error(job, exception)
    @exception = exception
    puts ""
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