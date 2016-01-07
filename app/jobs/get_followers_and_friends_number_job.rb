class GetFollowersAndFriendsNumberJob < Struct.new(:account)

  def perform
    account.update_stats
  end

  def success (job)
    Pusher.trigger('create_user', 'success', {
      name: account[:name],
      followers: account[:followers],
      friends: account[:following]
    })
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