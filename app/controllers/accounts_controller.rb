class AccountsController < ApplicationController
   before_action :twitter_oAuth, only: [:create, :followers, :friends]
   before_action :set_account, only: [:destroy, :followers, :friends]
   respond_to :html, :json

  def list
  	@accounts = Account.all
  end

  def new
  	@account = Account.new
  end

  # POST /accounts
  def create
    data =  @client.get '1.1/users/show.json', {:screen_name=>params[:account][:name]}
    params[:account][:followers] = data[:followers_count]
    params[:account][:following] = data[:friends_count]

    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to root_url, notice: 'account '+params[:account][:name]+' added, has '+params[:account][:followers].to_s+' followers and follows '+params[:account][:following].to_s+' people'}
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Account was successfully deleted.' }
    end
  end

  #delayed jobs: http://blog.andolasoft.com/2013/04/4-simple-steps-to-implement-delayed-job-in-rails.html https://www.youtube.com/watch?v=xVW4wRwwfJg
  # https://infinum.co/the-capsized-eight/articles/progress-bar-in-rails
  def followers
    @cursor = params[:cursor] || -1
    #@account.delay.getFollowers @client, @name, @cursor
    # @request = Twitter::REST::Request.new(@client, 'get', '1.1/followers/list.json',  {:screen_name=>@account[:name], :count=>200, :skip_status=> true, :include_user_entities=>false, :cursor=>@cursor})
    # @followers = @request.perform
    @job = Delayed::Job.enqueue GetFollowersJob.new(@client, @account[:name], @cursor)
    # @previous = @followers[:previous_cursor] > 0 ? @followers[:previous_cursor] : -1
    # @next = @followers[:next_cursor]
    # @followers = @followers[:users]
    # respond_with({:followers => @followers, :account => @account, :previous=>@previous,:next=>@next})
    @job_id = @job.id
    respond_with({:job_id =>@job_id})
  end

  def friends
    @cursor = params[:cursor] || -1
    @request = Twitter::REST::Request.new(@client, 'get', '1.1/friends/list.json',  {:screen_name=>@account[:name], :count=>200, :skip_status=> true, :include_user_entities=>false, :cursor=>@cursor})
    @friends = @request.delay.perform
    @previous = @friends[:previous_cursor] > 0 ? @friends[:previous_cursor] : -1
    @next = @friends[:next_cursor]
    @friends = @friends[:users]
    respond_with({:friends => @friends, :account => @account, :previous=>@previous,:next=>@next})
  end



  private
  	# Never trust parameters from the scary internet, only allow the white list through.
  	def account_params
	    params.require(:account).permit(:name, :followers, :following)
  	end

    def twitter_oAuth
      @client = Twitter::REST::Client.new do |config|
        #app auth allows for more requests every 15 minutes, possibly remove user key and secret
        config.consumer_key        = "bw6Ibw6DvDWZYTZJDgsIn12II"
        config.consumer_secret     = "lShJQA17tg93RVUCNhHRqAuHOOfSPvYqAJHihKbxT753GukKuJ"
        #config.access_token        = "4644992487-ZGV2FSbwYDCBgVyjMoAaoR3rXlUdnAwaCl9SYVE"
        #config.access_token_secret = "zbU5FfiibtontJiykO3ZInO4yzUDscByi9HjkOAGKy64G"
      end
    end

    def set_account
      @account = Account.find(params[:id])
    end
end
