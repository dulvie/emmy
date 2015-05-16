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
    @export_bank_file = ExportBankFile.new(export_bank_file_params)
    @export_bank_file.organization = current_organization
    respond_to do |format|
      if @export_bank_file.save
        format.html { redirect_to export_bank_files_url, notice: "#{t(:export_bank_file)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:export_bank_file)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
  end

  # DELETE
  def destroy
    @export_bank_file.destroy
    respond_to do |format|
      format.html { redirect_to export_bank_files_url, notice:  "#{t(:export_bank_files)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def export_bank_file_params
    params.require(:export_bank_file).permit(ExportBankFile.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path], ["#{t(:new)} #{t(:export_bank_file)}"]]
  end

  def show_breadcrumbs
   @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path], [@export_bank_file.reference]]
  end

end
