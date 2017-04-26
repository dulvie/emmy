class ImportBankFilesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create, :upload]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:import_bank_files)]]
    @import_bank_files = @import_bank_files.page(params[:page]).decorate
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
    @import_bank_file = current_organization.import_bank_files.build(import_bank_file_params)
    @import_bank_file.user = current_user
    respond_to do |format|
      if @import_bank_file.save
        format.html {
          redirect_to(import_bank_file_path(@import_bank_file),
                      notice: "#{t(:import_bank_file)} #{t(:was_successfully_created)}")
        }
      else
        format.html {
          flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import_bank_file)}"
          render :new
        }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @import_bank_file.update
        format.html { redirect_to import_bank_files_path, notice: "#{t(:import_bank_file)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:import_bank_file)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @import_bank_file.destroy
    respond_to do |format|
      format.html { redirect_to import_bank_files_path, notice:  "#{t(:import_bank_file)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def import_bank_file_params
    if params[:import_bank_file]
      params.require(:import_bank_file).permit(ImportBankFile.accessible_attributes.to_a)
    end
    # params.permit(current_organization, current_user)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:import_bank_files), import_bank_files_path],
                    ["#{t(:new)} #{t(:import_bank_file)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:import_bank_files), import_bank_files_path],
                    [@import_bank_file.reference]]
  end
end
