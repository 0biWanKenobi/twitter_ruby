class AccountsController < ApplicationController
  skip_before_action :verify_authenticity_token,  only: [:list]
  before_action :set_account, only: [:destroy, :followers, :friends, :getsavedfollowers]
  respond_to :html, :json, :js

  def list
  	@accounts = Account.all
  end

  def new
  	@account = Account.new
  end

  # POST /accounts
  def create
    # data =  @client.get '1.1/users/show.json', {:screen_name=>params[:account][:name]}
    # params[:account][:followers] = data[:followers_count]
    # params[:account][:following] = data[:friends_count]

    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to root_url, notice: 'account '+params[:account][:name]+' added'}
        Delayed::Job.enqueue GetFollowersAndFriendsNumberJob.new(@account)
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



  # def getsavedfollowers
  #   respond_to do |format|
  #     puts params
  #     @followers = Followers.where("twitter_id = '%s'", params[:data][:name]).order(:follower).page(params[:data][:cursor])
  #     # format.json {render json:  @followers.as_json             }
  #     format.json {render :json => {:data =>@followers.as_json , :attachmentPartial => render_to_string('accounts/_update_pagination.js', :layout => false, :locals => { :followers => @followers }) }}
  #   end
  # end

  def getsavedfriends
    respond_to do |format|
      puts params
      @friends = Friends.where("twitter_id = '%s'", params[:data][:name]).order(:friend).page(params[:data][:cursor])
      format.json {render json: @friends.as_json}
    end
  end


  def followers #possibly move code to model passing params to a model function
    @followers = Followers.get_by(@account[:name],params[:page])
    if params[:update] == nil && @followers.any?
      
      # puts "\e[32mFollowers found in db!\e[0m"
      respond_to do |format|
        format.html { render 'followers', :locals =>{:followers => @followers} }
        format.json {render :json => {:data =>@followers.as_json , :attachmentPartial => render_to_string('accounts/_update_pagination.js', :layout => false, :locals => { :followers => @followers }) }}
      end
    elsif params[:update]
      # puts "\e[32mFetching followers\e[0m"
      Delayed::Job.enqueue GetFollowersJob.new(@account)    
      respond_to do |format|
        format.html {render :nothing => true}      #avoid internal server error caused by @followers not being defined in view
      end
    else #safety case, should never be reached because view always asks for specific page and this would be called when there are no followers on that db page
      respond_to do |format|
        format.json {render :json => {:data =>{} , :attachmentPartial => render_to_string('accounts/_update_pagination.js', :layout => false, :locals => { :followers => @followers }) }}
      end
    end
  end

  def friends
    Delayed::Job.enqueue GetFriendsJob.new(@account)    
    respond_to do |format|
      format.html {render "friends"}      
    end
  end



  private
  	# Never trust parameters from the scary internet, only allow the white list through.
  	def account_params
	    params.require(:account).permit(:name, :followers, :following)
  	end

    def set_account
      id = params[:id]
      @account = Account.find(id)

    end
end
