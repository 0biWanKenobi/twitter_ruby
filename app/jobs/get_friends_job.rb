class GetFriendsJob < Struct.new(:account)

  def perform
    @last_loop = account.get_friends
    @last_loop+=1
  end

  def success (job)
    Pusher.trigger('load_friends', 'update', { percentage: 100, cursor: @last_loop, name: account[:name], id: account.id })
  end

   def error(job, exception)
    @exception = exception
  end

  def reschedule_at(current_time, attempts)
    if at_rate_limit?      
      puts "reschedule at "+@exception.rate_limit.reset_at.to_s      
      puts "default reschedule would be at "+(current_time + 5.seconds**attempts).to_s    
      @exception.rate_limit.reset_at  
    else #default behaviour
      current_time + 5.seconds**attempts
    end
  end

  def queue_name
    'get_friends'
  end

  private

  def at_rate_limit?
    @exception.is_a?(Twitter::Error::TooManyRequests)
  end

end