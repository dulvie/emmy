class TransfersController < ApplicationController
  load_and_authorize_resource

  # Since load_and_authorize doesnt do this for non crud actions.
  before_filter :find_transaction, only: [:send_package, :receive_package]

  # GET /transfers
  # GET /transfers.json
  def index
    @transfers = TransferDecorator.decorate_collection(@transfers)
    @breadcrumbs = [['Transfers']]
  end

  # GET /transfers/1
  # GET /transfers/1.json
  def show
    @breadcrumbs = [['Transfers', transfers_path], [@transfer.created_at]]
  end

  # GET /transfers/new
  def new
    @transfer.comments.build
    @breadcrumbs = [['Transfers', transfers_path], ['New transfer']]
  end

  # POST /transfers
  # POST /transfers.json
  def create
    @transfer = new_transfer

    respond_to do |format|
      if @transfer.save
        format.html { redirect_to transfer_path(@transfer), notice: 'Transfer transaction was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @transfer }
      else
        format.html { render action: 'new' }
        #format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  def send_package
    @transfer.send_package
    respond_to do |format|
      format.html { redirect_to transfers_path, notice: t(:transfer_marked_as_sent) }
      #format.json { render action: 'show', status: :created, location: @transfer }
    end
  end

  def receive_package
    @transfer.receive_package
    respond_to do |format|
      format.html { redirect_to transfers_path, notice: t(:transfer_marked_as_received) }
      #format.json { render action: 'show', status: :created, location: @transfer }
    end
  end

  private

    def find_transaction
      @transaction = Transaction.find params[:id]
      authorize! :manage, @transaction
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
      comment_p = comments_params.dup
      comment_p[:user_id] = current_user.id
      transfer.comments.build(comment_p)
      transfer
    end
end
