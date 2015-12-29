class AccountsController < ApplicationController
  def list
  	@accounts = Account.all
  end

  def new
  	@account = Account.new
  end


  private
  	# Never trust parameters from the scary internet, only allow the white list through.
  	def account_params
	  params.require(:account).permit(:name, :followers, :following)
  	end
end
