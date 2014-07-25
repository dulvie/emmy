class ManualsController < ApplicationController

  load_and_authorize_resource
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /manuals
  # GET /manuals.json
  def index
    @breadcrumbs = [['Manuals']]
    @manuals = Manual.page(params[:page]).per(8)
  end

  # GET /manuals/1
  # GET /manuals/1.json
  def show
    render 'edit'
  end

  # GET /manuals/1/edit
  def edit
  end

  # GET /manuals/new
  def new
    @manual.product_transaction = ProductTransaction.new
    @manual.comments.build
  end

  # POST /manuals
  # POST /manuals.json
  def create
    @manual = new_manual
    respond_to do |format|
      if @manual.save
        format.html { redirect_to manuals_path, notice: "#{t(:manual_transaction)} #{t(:was_successfully_created)}" }
        #format.json { render action: 'show', status: :created, location: @manual }
      else
        format.html { render action: 'new' }
        #format.json { render json: @manual.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manuals/1
  # DELETE /manuals/1.json
  def destroy
    @manual.destroy
    respond_to do |format|
      format.html { redirect_to manuals_url, notice: 'manual was successfully deleted.' }
      #format.json { head :no_content }
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
    def product_transaction_params
      params.require(:manual).permit(ProductTransaction.accessible_attributes.to_a)
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
      manual.product_transaction = ProductTransaction.new product_transaction_params
      comment_p = params[:manual][:comments_attributes][:"0"]
      comment_p[:user_id] = current_user.id
      manual.comments.build(comment_p)
      manual
    end
end
