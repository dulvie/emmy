class Api::UsersController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @user = User.new(user_params)
    @user.default_organization_id = params[:user][:organization_id]
    if params[:user][:role] == 'admin'
      @user.organization_roles.build(organization_id: params[:user][:organization_id], name: OrganizationRole::ROLE_ADMIN)
    end
    if params[:user][:role] == 'seller'
      @user.organization_roles.build(organization_id: params[:user][:organization_id], name: OrganizationRole::ROLE_STAFF)
    end
    respond_to do |format|
      if @user.save
        create_contact if params[:user][:fullname]
        format.json { render json: @user.id, status: :created }
       else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def create_contact
      @contact_relation = @user.contact_relations.build
      @contact_relation.organization_id = params[:user][:organization_id]
      
      @contact = @contact_relation.build_contact
      @contact.organization_id = params[:user][:organization_id]
      @contact.name = params[:user][:fullname]
      @contact.email = params[:user][:email]
      @contact.save

      @contact_relation.contact = @contact
      @contact_relation.save
    end

    def user_params
      params.require(:user).permit(User.accessible_attributes.to_a)
    end
end