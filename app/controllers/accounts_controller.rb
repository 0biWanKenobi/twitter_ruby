class AccountsController < ApplicationController
   before_action :twitter_oAuth, only: [:create]
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
    #@account = Account.new(account_params)
    end



    #   else
    #     format.html { render :new }
    #     format.json { render json: @account.errors, status: :unprocessable_entity }
    #   end

  end


  private
  	# Never trust parameters from the scary internet, only allow the white list through.
  	def account_params
	    params.require(:account).permit(:name, :followers, :following)
  	end

    def twitter_oAuth
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "bw6Ibw6DvDWZYTZJDgsIn12II"
        config.consumer_secret     = "lShJQA17tg93RVUCNhHRqAuHOOfSPvYqAJHihKbxT753GukKuJ"
        config.access_token        = "4644992487-ZGV2FSbwYDCBgVyjMoAaoR3rXlUdnAwaCl9SYVE"
        config.access_token_secret = "zbU5FfiibtontJiykO3ZInO4yzUDscByi9HjkOAGKy64G"
      end
    end
end
