class ManualsController < ApplicationController
  load_and_authorize_resource

  # GET /manuals
  # GET /manuals.json
  def index
    @breadcrumbs = [['Manuals']]
  end

  # GET /manuals/1
  # GET /manuals/1.json
  def show
    @breadcrumbs = [['Manuals', manuals_path], [@manual.created_at]]
  end

  # GET /manuals/new
  def new
    @manual.transaction = Transaction.new
    @manual.comments.build
    @breadcrumbs = [['Manuals', manuals_path], ['New manual']]
  end

  # POST /manuals
  # POST /manuals.json
  def create
    @manual = new_manual

    respond_to do |format|
      if @manual.save
        format.html { redirect_to manual_path(@manual), notice: 'Manual transaction was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @manual }
      else
        format.html { render action: 'new' }
        #format.json { render json: @manual.errors, status: :unprocessable_entity }
      end
    end
  end


  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(Transaction.accessible_attributes.to_a)
    end

    def comments_params
      params.require(:comments).permit(Comment.accessible_attributes.to_a)
    end

    def new_manual
      manual = Manual.new
      manual.user_id = current_user.id
      manual.transaction = Transaction.new transaction_params
      comment_p = comments_params.dup
      comment_p[:user_id] = current_user.id
      manual.comments.build(comment_p)
      manual
    end
end