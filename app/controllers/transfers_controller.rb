class TransfersController < ApplicationController
  load_and_authorize_resource  through: :current_organization
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  # Since load_and_authorize doesnt do this for non crud actions.
  before_filter :find_transfer, only: [:send_package, :receive_package]

  # GET /transfers
  # GET /transfers.json
  def index
    @breadcrumbs = [['Transfers']]
    transfers = TransferDecorator.decorate_collection(@transfers.order('id DESC'))
    @transfers = Kaminari.paginate_array(transfers).page(params[:page])
  end

  # GET /transfers/1
  # GET /transfers/1.json
  def show
    @warehouses = current_organization.warehouses
  end

  # GET /transfers/new
  def new
    @transfer.comments.build
    @warehouses = current_organization.warehouses
    gon.push warehouses: ActiveModel::ArraySerializer.new(@warehouses, each_serializer: WarehouseSerializer)
  end

  # POST /transfers
  # POST /transfers.json
  def create
    @transfer = new_transfer
    respond_to do |format|
      if @transfer.save
        format.html { redirect_to transfers_path, notice: "#{t(:transfer_transaction)} #{t(:was_successfully_created)}" }
        # format.json { render action: 'show', status: :created, location: @transfer }
      else
        @warehouses = current_organization.warehouses
        gon.push warehouses: ActiveModel::ArraySerializer.new(@warehouses, each_serializer: WarehouseSerializer)
        format.html { render action: 'new' }
        # format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfer/1
  # DELETE /transfer/1.json
  def destroy
    @transfer.destroy
    respond_to do |format|
      format.html { redirect_to transfers_url, notice: 'transfer was successfully deleted.' }
      # format.json { head :no_content }
    end
  end

  def send_package
    if  @transfer.send_package(params[:state_change_at])
      notice = t(:transfer_marked_as_sent)
    else
      notice = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to transfers_path, notice: notice }
      # format.json { render action: 'show', status: :created, location: @transfer }
    end
  end

  def receive_package
    if @transfer.receive_package(params[:state_change_at])
      notice = t(:transfer_marked_as_received)
    else
      notice = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to transfers_path, notice: notice }
      # format.json { render action: 'show', status: :created, location: @transfer }
    end
  end

  private

  def new_breadcrumbs
    @breadcrumbs = [['Transfers', transfers_path], ['New transfer']]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Transfers', transfers_path], [@transfer.created_at]]
  end

  def find_transfer
    @transfer = current_organization.transfers.find params[:id]
    authorize! :manage, @transfer
  end

  def comments_params
    params.require(:comments).permit(Comment.accessible_attributes.to_a)
  end

  def transfer_params
    params.require(:transfer).permit(Transfer.accessible_attributes.to_a)
  end

  def new_transfer
    transfer = Transfer.new transfer_params
    transfer.user_id = current_user.id
    transfer.organization_id = current_organization.id
    comment_p = params[:transfer][:comments_attributes][:"0"]
    comment_p[:user_id] = current_user.id
    c = transfer.comments.build(comment_p)
    c.organization_id = current_organization.id
    transfer
  end
end
