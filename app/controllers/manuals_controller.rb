class ManualsController < ApplicationController
  load_and_authorize_resource through: :current_organization, except: :create
  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /manuals
  # GET /manuals.json
  def index
    @breadcrumbs = [['Manuals']]
    @manuals = current_organization.manuals.page(params[:page])
                                           .order('created_at desc')
  end

  # GET /manuals/1
  # GET /manuals/1.json
  def show
    init_collection
    render 'edit'
  end

  # GET /manuals/1/edit
  def edit
    init_collection
  end

  # GET /manuals/new
  def new
    init_collection
    @manual.batch_transaction = BatchTransaction.new
    @manual.comments.build
    gon.push batches: ActiveModel::Serializer::CollectionSerializer.new(@batches, each_serializer: BatchSerializer)
  end

  # POST /manuals
  # POST /manuals.json
  def create
    authorize! :create, @manual
    @manual = new_manual
    respond_to do |format|
      if @manual.save
        format.html { redirect_to manuals_path, notice: "#{t(:manual_transaction)} #{t(:was_successfully_created)}" }
        # format.json { render action: 'show', status: :created, location: @manual }
      else
        init_collection
        gon.push batches: ActiveModel::Serializer::CollectionSerializer.new(@batches, each_serializer: BatchSerializer)
        format.html { render action: 'new' }
        # format.json { render json: @manual.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manuals/1
  # DELETE /manuals/1.json
  def destroy
    @manual.destroy
    respond_to do |format|
      format.html { redirect_to manuals_url, notice: 'manual was successfully deleted.' }
      # format.json { head :no_content }
    end
  end

  private

  def new_breadcrumbs
    @breadcrumbs = [['Manuals', manuals_path], ["#{t(:new)} #{t(:manual)}"]]
  end

  def edit_breadcrumbs
    @breadcrumbs = [['Manuals', manuals_path], [@manual.created_at]]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def batch_transaction_params
    params.require(:manual).permit(:warehouse, :warehouse_id, :batch, :batch_id, :parent_id, :parent, :quantity)
  end

  def comments_params
    params.require(:manual).require(:comments_attributes).require(:"0").permit(:body)
  end

  def new_manual
    manual = Manual.new
    manual.user_id = current_user.id
    manual.organization = current_organization

    manual.batch_transaction = BatchTransaction.new batch_transaction_params
    manual.batch_transaction.organization_id = current_organization.id

    c = manual.comments.build comments_params
    c.user_id = current_user.id
    c.organization_id = current_organization.id
    manual
  end

  def init_collection
    @warehouses = current_organization.warehouses
    @batches = current_organization.batches
    message = "#{I18n.t(:warehouses)} #{I18n.t(:missing)}" if @warehouses.size == 0
    message = "#{I18n.t(:batches)} #{I18n.t(:missing)}" if @batches.size == 0
    redirect_to helps_show_message_path(message:message) if @warehouses.size == 0 || @batches.size == 0
  end
end
