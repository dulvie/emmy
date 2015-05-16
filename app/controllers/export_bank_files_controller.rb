class ExportBankFilesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [["#{t(:export_bank_files)}"]]
    @export_bank_files = @export_bank_files.page(params[:page]).decorate
    # redirect_to helps_show_message_path()+"&message="+I18n.t(:under_development), notice: "Infomessage"
  end

  # GET
  def new
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
  end

  # PATCH/PUT
  def update
  end

  # DELETE
  def destroy
  end

  private

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path], ["#{t(:new)} #{t(:export_bank_file)}"]]
  end

  def show_breadcrumbs
   @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path], [@export_bank_file.reference]]
  end

end
