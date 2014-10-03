module Admin

  class UsersController < Admin::ApplicationController
    load_and_authorize_resource :organization
    load_and_authorize_resource through: :organization
    before_filter :new_breadcrumbs, only: [:new, :create]
    before_filter :show_breadcrumbs, only: [:show, :update_role]

    def new
    end

    def show
    end

    # Create a new user and add access to the current organization as 'staff'
    def create
      @user = User.new(user_params)
      @user.organization_roles.build(organization_id: @organization.id, name: OrganizationRole::ROLE_STAFF)
      @user.default_organization = @organization
      if @user.save
        redirect_to admin_organization_path(@organization),
                    notice: "#{t(:new)} #{t(:user)} #{t(:was_successfully_created)}"
      else
        render :new
      end
    end

    def update_role
    end

    private

    def user_params
      params.require(:user).permit(User.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [
        [t(:organizations), admin_organizations_path],
        [@organization.name, admin_organization_path(@organization)],
        ["#{t(:new)} #{t(:user)}"]
      ]
    end

    def show_breadcrumbs
      @breadcrumbs = [[t(:organizations), admin_organizations_path], [@user.name]]
    end
  end
end
