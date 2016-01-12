class AccountsController < ApplicationController
  #skip_before_action :verify_authenticity_token,  only: [:list]
  before_action :set_account, only: [:destroy, :followers, :friends, :getsavedfollowers, :pagination_followers, :pagination_friends]
  respond_to :html, :json, :js

  def list
  	@accounts = Account.all
  end

  def new
  	@account = Account.new
  end

  # POST /accounts
  def create

    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to root_url, notice: 'Processing account '+params[:account][:name]}
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



  def followers #possibly move code to model passing params to a model function
    @followers = @account.followers.page params[:page]
    if params[:update] == nil && followers_in_db = @followers.any?
      respond_to do |format|
        format.html { render 'followers', locals:{followers: @followers, page:params[:page]} }
        format.json {render json: @followers.as_json}
      end
    elsif params[:update] || !followers_in_db
      Delayed::Job.enqueue GetFollowersJob.new(@account)    
      respond_to do |format|
        format.html {render 'followers', locals:{page: params[:page]}}    
      end
    end
  end

  def friends
    @friends = @account.friends.page params[:page]
    if params[:update] == nil && friends_in_db = @friends.any?
      puts "friends in db" 
      respond_to do |format|
        format.html { render 'friends', locals:{friends: @friends, page:params[:page]} }
        format.json {render json: @friends.as_json}
      end
    elsif params[:update] || !friends_in_db
      puts "job started"
      Delayed::Job.enqueue GetFriendsJob.new(@account)   
      respond_to do |format|
        format.html {render 'friends', locals:{page: params[:page]}}     
      end
    end
  end

  def pagination_followers
    @followers = @account.followers.page params[:page]
    respond_to do |format|
      format.json {render json: {pagination:render_to_string('accounts/_update_pagination.js', layout: false, locals: { relation: @followers, action: 'followers' }) } }      
    end
  end

  def pagination_friends
    @friends = @account.friends.page params[:page]
    respond_to do |format|
      format.json {render json: {pagination: render_to_string('accounts/_update_pagination.js', layout: false, locals: { relation: @friends, action: 'friends' })  } }      
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
