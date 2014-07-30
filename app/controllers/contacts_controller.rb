class ContactsController < ApplicationController

  load_and_authorize_resource

  before_filter :find_and_authorize_parent
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def new
    @contact = @parent.contacts.build
    logger.info "contact parent: #{@contact.parent_type}"
    logger.info "contact: #{@contact.inspect}"
    logger.info "parent: #{@parent.inspect}"
    @contact_form_url = contacts_path(parent_type: @contact.parent_type, parent_id: @contact.parent_id)
  end

  def show
    @contact_form_url = contact_path(@contact, parent_type: @contact.parent_type, parent_id: @contact.parent_id)
  end

  def create
    @contact = @parent.contacts.build contact_params
    respond_to do |format|
      if @contact.save
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:contact_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:contact)}"
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:contact)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:contact)}"
        format.html { render :show }
      end
    end
  end

  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:contact)} #{t(:was_destroyed)}" }
      #format.json { head :no_content }
    end
  end


  private

    def find_and_authorize_parent

      # if contact exists, but no parent_type, add from contact.
      unless params.has_key?(:parent_type) && @contact
        params[:parent_type] = @contact.parent_type
        params[:parent_id] = @contact.parent_id
      end

      unless Contact::VALID_PARENT_TYPES.include? params[:parent_type]
        logger.info "SECURITY: invalid parent_type(#{params[:parent_type]}) sent to #{request.original_url} "
        redirect_to '/'
        return false
      end

      parent_class = params[:parent_type].constantize
      @parent = parent_class.find(params[:parent_id])
      authorize! :manage, @parent
    end

    def contact_params
        params.require(:contact).permit(Contact.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [["#{@parent.class.name.pluralize}", send("#{@parent.class.name.downcase}s_path")],
        [@parent.parent_name, @parent], ["#{t(:new)} #{t(:contact)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [["#{@contact.parent_type.pluralize}", send("#{@parent.class.name.downcase}s_path")],
        [@contact.parent_name, @contact.parent], ["#{t(:contacts)}(#{@contact.name})"]]
    end

end
