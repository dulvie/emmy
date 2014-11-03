class ManualsController < ApplicationController
  load_and_authorize_resource through: :current_organization
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /manuals
  # GET /manuals.json
  def index
    @breadcrumbs = [['Manuals']]
    @manuals = current_organization.manuals.page(params[:page])
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
  end

  # POST /manuals
  # POST /manuals.json
  def create
    @manual = new_manual
    respond_to do |format|
      if @manual.save
        format.html { redirect_to manuals_path, notice: "#{t(:manual_transaction)} #{t(:was_successfully_created)}" }
        # format.json { render action: 'show', status: :created, location: @manual }
      else
        init_collection
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
    params.require(:manual).permit(BatchTransaction.accessible_attributes.to_a)
  end

  def commentsx_params
    params.require(:comments).permit(Comment.accessible_attributes.to_a)
  end

  def comments_params
    params.require([:comments_attributes][:'0'])
  end

  def new_manual
    manual = Manual.new
    manual.user_id = current_user.id
    manual.organization = current_organization
    manual.batch_transaction = BatchTransaction.new batch_transaction_params
    manual.batch_transaction.organization_id = current_organization.id
    comment_p = params[:manual][:comments_attributes][:"0"]
    comment_p[:user_id] = current_user.id
    c = manual.comments.build(comment_p)
    c.organization_id = current_organization.id
    manual
  end

  def init_collection
    @warehouses = current_organization.warehouses
    @batches = current_organization.batches
  end
end
