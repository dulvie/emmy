class ContactRelationsController < ApplicationController

  load_and_authorize_resource

  before_filter :find_and_authorize_parent
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def new
    @contact_relation = @parent.contact_relations.build
    @contact = @parent.contacts.build
    init_new
  end

  def show
    init_show
  end

  def create

    if params[:contact][:id] != ''
      @contact = Contact.find(params[:contact][:id])
      @contact.update_attributes contact_params
    else
      @contact = @parent.contacts.build contact_params
    end

    @contact.organisation = current_organisation
    @contact_relation = @parent.contact_relations.build
    @contact_relation.organisation = current_organisation

    respond_to do |format|
      if @contact.save
        @contact_relation.contact = @contact
        if @contact_relation.save
          format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:contact_added)}" }
        else
          flash.now[:danger] = "#{t(:failed_to_add)} #{t(:contact)}"
          init_new
          format.html { render :new }
        end
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:contact)}"
        init_new
        format.html { render :new }
      end
    end
  end

  def update
    @contact = Contact.find(params[:contact][:id])
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:contact)} #{t(:was_successfully_updated)}" }
      else
        init_show
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:contact)}"
        format.html { render :show }
      end
    end
  end

  def destroy
    @contact_relation.destroy
    respond_to do |format|
      format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:contact)} #{t(:was_destroyed)}" }
      #format.json { head :no_content }
    end
  end


  private

    def init_new
      @new = true
      @contact_relation_form_url = contact_relations_path(parent_type: @contact_relation.parent_type, parent_id: @contact_relation.parent_id)
      @contacts = Contact.where.not(id:@parent.contacts.map(&:id))
      gon.push contacts: ActiveModel::ArraySerializer.new(@contacts, each_serializer: ContactSerializer)
    end

    def init_show
      @new = false
      @contact = @contact_relation.contact
      @contact_relation_form_url = contact_relation_path(parent_type: @contact_relation.parent_type, parent_id: @contact_relation.parent_id)
    end

    def find_and_authorize_parent

      # if contact exists, but no parent_type, add from contact.
      unless params.has_key?(:parent_type) && @contact_relation
        params[:parent_type] = @contact_relation.parent_type
        params[:parent_id] = @contact_relation.parent_id
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
      @breadcrumbs = [["#{@parent.class.name.pluralize}", send("#{@parent.class.name.downcase}s_path")],
        [@parent.parent_name, @parent], ["#{t(:contacts)}(#{@contact_relation.contact.name})"]]
    end

end