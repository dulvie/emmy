class ImportBankFilesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Import bank files']]
    @import_bank_files = @import_bank_files.page(params[:page]).decorate
    @bank_trans = current_organization.bank_file_transactions.where("execute = 'import'").order("created_at DESC").first
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
    @import_bank_file = Services::ImportBankFileCreator.new(current_organization, current_user)
    respond_to do |format|
      if true # @import_bank_file.read_and_save_nordea
        format.html { redirect_to import_bank_files_path, notice: "#{t(:import_bank_file)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import_bank_file)}"
        format.html {redirect_to import_bank_files_path}
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @import_bank_file.update()
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

  # UPLOAD
  def upload
    @import_bank_file = ImportBankFile.new
  end

  # Create fromn upload
  def create_from_upload
    uploaded = params[:import_bank_file][:upload]
    tempfile = uploaded.tempfile
    directory = "#{Rails.root}/tmp/uploads"
    file_name = "#{current_organization.slug}_bank_file.csv"
    path = File.join(directory, file_name)
    File.open(path, "wb") { |f| f.write(tempfile.read) }

    @bank_file_trans = BankFileTransaction.new
    @bank_file_trans.execute = 'import'
    @bank_file_trans.complete = 'false'
    @bank_file_trans.directory = directory
    @bank_file_trans.file_name = file_name
    @bank_file_trans.user = current_user
    @bank_file_trans.organization = current_organization
    if @bank_file_trans.save
      redirect_to import_bank_files_path, notice: "#{t(:file_uploaded)}"
    else
      flash.now[:danger] = "#{t(:file_upload)} #{t(:failed)}"
      render :upload
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def import_bank_file_params
    params.require(:import_bank_file).permit(ImportBankFile.accessible_attributes.to_a)
    # params.permit(current_organization, current_user)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:import_bank_files)}", import_bank_files_path], ["#{t(:new)} #{t(:import_bank_file)}"]]
  end

  def show_breadcrumbs
   @breadcrumbs = [["#{t(:import_bank_files)}", import_bank_files_path], [@import_bank_file.reference]]
  end
end
