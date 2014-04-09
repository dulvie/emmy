class UsersController < ApplicationController
  # @fixme CanCan authorization MUST be implemented here.
  # all actions needs to be locked down to admin only.

  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_roles, :update_roles]

  before_action :check_authorization

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    @breadcrumbs = [['Users']]
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @breadcrumbs = [['Users', users_path], ['New user']]
  end

  # GET /users/1/edit
  def edit
    @breadcrumbs = [['Users', users_path], [@user.name]]
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

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
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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

  # Some admin only stuff
  # The find stuff/authorize stuff is done by load_and_authorize_resource
  # for the other actions..
  def edit_roles
    authorize! :manage, Role
    @breadcrumbs = [['Users', users_path], [@user.name, edit_user_path(@user)], ['Roles']]
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
        format.html { redirect_to edit_roles_user_path(@user), notice: 'User roles was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit_roles' }
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
        authorize! :manage, @user
      else
        authorize! :manage, User
      end
    end

end
