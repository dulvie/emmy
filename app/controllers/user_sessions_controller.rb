class UserSessionsController < Devise::SessionsController
  layout "single"

  def create
    super do |resource|
      I18n.locale = current_user.default_locale
    end
  end
end
