class ProfileController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash.now[:notice] = "#{t(:your_profile)} #{t(:was_successfully_updated}"
    else
      flash.now[:error] = "#{t(:failed_to_update)} #{t(:your_profile)}."
    end
    render :show
  end
end
