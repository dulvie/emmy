class ContactsController < ApplicationController

  load_and_authorize_resource

  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def index
    @breadcrumbs = [['Contacts']]
    @contacts = Contact.order("name").page(params[:page]).per(8)
  end

  def new
  end

  def show
  end

  def create
    @contact = Contact.new contact_params
    @contact.organisation = current_organisation
    respond_to do |format|
      if @contact.save
        format.html { redirect_to contacts_path, notice: "#{t(:contact_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:contact)}"
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to contacts_path, notice: "#{t(:contact)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:contact)}"
        format.html { render :show }
      end
    end
  end

  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_path, notice: "#{t(:contact)} #{t(:was_destroyed)}" }
      #format.json { head :no_content }
    end
  end


  private

    def contact_params
        params.require(:contact).permit(Contact.accessible_attributes.to_a)
    end

    def new_breadcrumbs
       @breadcrumbs = [['Contacts', contacts_path], ["#{t(:new)} #{t(:customer)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [['Contacts', contacts_path], [@contact.name]]
    end

end
