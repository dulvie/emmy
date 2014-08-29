class UsersController < ApplicationController
  # @fixme CanCan authorization MUST be implemented here.
  # all actions needs to be locked down to admin only.

  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_roles]

  before_action :check_authorization

  # GET /users
  # GET /users.json
  def index
    @users = User.all.order(:name).page(params[:page]).per(8)
    @breadcrumbs = [['Users']]
  end

  # GET /users/1
  # GET /users/1.json
  def show
      @breadcrumbs = [['Users', users_path], [@user.email]]
    if @user.contact_relation.nil?
      @contact_relation = @user.build_contact_relation
      @contact = @contact_relation.build_contact
      @contact_relation_form_url = contact_relations_path(parent_type: @contact_relation.parent_type, parent_id: @contact_relation.parent_id)
    else
      @contact_relation = @user.contact_relation
      @contact = @user.contacts
      @contact_relation_form_url = contact_relation_path(parent_type: 'User', parent_id: @user.id)
    end
  end

  # GET /users/new
  def new
    @user = User.new
    @breadcrumbs = [['Users', users_path], ['New user']]
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    authorize! :create, @user

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update

    # @todo Maybe this can be refactored into service objects.

    # Remove password from params if no new password is supplied.
    u_params = user_params
    if u_params[:password] && u_params[:password].empty?
      u_params.delete(:password)
      u_params.delete(:password_confirmation)
    end

    # If authenticated user is updating self with new locale, change current locale.
    if (@user.id == current_user.id && u_params[:default_locale] !=  I18n.locale)
      I18n.locale = u_params[:default_locale]
      params[:locale] = u_params[:default_locale]
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        @breadcrumbs = [['Users', users_path], [@user.email]]
        format.html { render action: 'show' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # @todo Refactor me!
  # This is quite hariy and not very clean...
  # Not sure if I want to put this into a @user.update_roles or not..
  def update_roles
    authorize! :manage, Role

    # Extract the role_ids
    role_ids = []
    params[:user][:role_ids].each do |role_id|
      role_ids << role_id.to_i unless role_id.empty?
    end

    # Get the actual role objects
    logger.info "will try and find roles: #{role_ids}"
    roles = Role.find role_ids
    logger.info "will ensure #{roles.collect{|r| r.name}.join(", ")} is the roles for #{@user.name}"

    # Cache the old user roles.
    user_roles_before_update = @user.roles.collect{|r| r}

    # Add the roles that aren't already present
    roles.each do |role|
      logger.info "adding #{role.name} to user"
      @user.roles << role unless @user.role? role.name
    end

    # Remove the roles that are not present in the request params
    user_roles_before_update.each do |role|
      unless role_ids.include? role.id
        logger.info "removing #{role.name} to user"
        @user.roles.delete role
      end
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_path(@user), notice: 'User roles was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'show' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user]
    end

    def check_authorization
      if @user
        if params[:action].eql? 'show' # Let everybody that has read access see the user info.
          authorize! :read, @user
        else
          authorize! :manage, @user
        end
      else
        authorize! :manage, User
      end
    end

end
