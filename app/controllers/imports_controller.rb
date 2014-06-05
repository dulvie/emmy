class ImportsController < ApplicationController

  load_and_authorize_resource
 
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:edit, :update]
 
 
  # GET /imports
  # GET /imports.json
  def index
    @breadcrumbs = [[t(:imports)]]
    @imports = @imports.collect{|import| import.decorate}
  end

  # GET /imports/1
  # GET /imports/1.json
  def show
    @breadcrumbs = [['Imports', imports_path], [@import.description]]
    @import = @import.decorate
  end
  
  # GET /imports/new
  def new
  end
  
  # GET /imports/1/edit
  def edit
    @costitems = @import.costitems.collect{|costitem| costitem.decorate}
  end

  # POST /imports
  # POST /imports.json
  def create
    @import = Import.new(import_params)

    respond_to do |format|
      if @import.save
      
        #citems = Import.find(1).costitems        
        #citems.each do |ci|
        #  copy = ci.dup
        #  copy.parent_id = @import.id
        #  copy.save
        #end
        
        format.html { redirect_to edit_import_path(@import), notice: 'import was successfully created.'}
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        format.html { render action: 'new' }
      end
    end    
  end
  
  def destroy
    @import.destroy
    respond_to do |format|
      format.html { redirect_to imports_path, notice: "#{t(:import)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end
  
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_params
      params.require(:import).permit(Import.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Imports', imports_path], ["#{t(:new)} #{t(:import)}"]]
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Imports', imports_path], [@import.description]]
    end
end
