class Api::UsersController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        if params[:user][:role] == 'admin'
          @user.roles <<  Role.first
          @user.save
        end
        if params[:user][:role] == 'seller'
          @user.roles <<  Role.last
          @user.save
        end
        format.json { render json: @user, status: :created }
       else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(User.accessible_attributes.to_a)
    end
end