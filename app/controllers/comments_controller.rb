class CommentsController < ApplicationController
  load_and_authorize_resource
  before_filter :find_and_authorize_parent
  before_filter :show_breadcrumbs, only: [:show, :update]

  def new
    @comment = @parent.comments.build
    logger.info "comment parent: #{@comment.parent_type}"
    logger.info "comment: #{@comment.inspect}"
    logger.info "parent: #{@parent.inspect}"
    @comment_form_url = comments_path(parent_type: @comment.parent_type, parent_id: @comment.parent_id)
  end

  def show
    @comment_form_url = comment_path(@comment, parent_type: @comment.parent_type, parent_id: @comment.parent_id)
  end

  def create
    @comment = @parent.comments.build comment_params
    respond_to do |format|
      if @comment.save
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:comment_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:comment)}"
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:comment)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:comment)}"
        format.html { render :show }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:comment)} #{t(:was_destroyed)}" }
      #format.json { head :no_comment }
    end
  end


  private

    def find_and_authorize_parent

      # if comment exists, but no parent_type, add from comment.
      unless params.has_key?(:parent_type) && @comment
        params[:parent_type] = @comment.parent_type
        params[:parent_id] = @comment.parent_id
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

    def comment_params
        params.require(:comment).permit(Comment.accessible_attributes.to_a)
    end

    def show_breadcrumbs
      @breadcrumbs = [["#{@comment.parent_type.pluralize}", send("#{@parent.class.name.downcase}_path")], [@comment.parent_name, @comment.parent], ["#{t(:comments)}(#{@comment.body})"]]
    end

end
