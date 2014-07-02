class CommentsController < ApplicationController

  load_and_authorize_resource
  before_filter :find_and_authorize_parent
  
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def index
    @comments = Comment.where('parent_id= ?', 0)
  end

  def new
    if @parent.nil?
      @comment = Comment.new
      @comment_form_url = comments_path(parent_type: 'nil', parent_id: 0)
    else
      @comment = @parent.comments.build
      @comment_form_url = comments_path(parent_type: @comment.parent_type, parent_id: @comment.parent_id)
    end   
  end

  def show
    @comment_form_url = comment_path(@comment, parent_type: @comment.parent_type, parent_id: @comment.parent_id)
  end

  def create
    if @parent.nil?
      @comment = Comment.create comment_params
      @comment.parent_type = 'nil'
      @comment.parent_id = 0
      redirect_path = comments_path
    else
      @comment = @parent.comments.build comment_params
      redirect_path = edit_polymorphic_path(@parent)
    end
    @comment.user = current_user
    respond_to do |format|
      if @comment.save
        format.html { redirect_to redirect_path, notice: "#{t(:comment_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:comment)}"
        format.html { render :new }
      end
    end
  end

  def update
    if @parent.nil?
      redirect_path = comments_path
    else
      redirect_path = edit_polymorphic_path(@parent)
    end
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to redirect_path, notice: "#{t(:comment)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:comment)}"
        format.html { render :show }
      end
    end
  end

  def destroy
    if @parent.nil?
      redirect_path = comments_path
    else
      redirect_path = edit_polymorphic_path(@parent)
    end
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: "#{t(:comment)} #{t(:was_destroyed)}" }
      #format.json { head :no_comment }
    end
  end


  private

    def find_and_authorize_parent

      # if comment exists, but no parent_type, add from comment.
      if !params.has_key?(:parent_type) && !@comment.nil?
        params[:parent_type] = @comment.parent_type
        params[:parent_id] = @comment.parent_id
      end

      logger.info "Kollar:: #{params[:parent_type]}"
      if  !params.has_key?(:parent_type)
         params[:parent_type] = 'nil'
         params[:parent_id] = 0
      end

      unless Comment::VALID_PARENT_TYPES.include? params[:parent_type]
        logger.info "SECURITY: invalid parent_type(#{params[:parent_type]}) sent to #{request.original_url} "
        redirect_to '/'
        return false
      end
      
      if params[:parent_type] != 'nil'
        parent_class = params[:parent_type].constantize
        @parent = parent_class.find(params[:parent_id])
        authorize! :manage, @parent
      end  
    end

    def comment_params
        params.require(:comment).permit(Comment.accessible_attributes.to_a)
    end

    def show_breadcrumbs
      if !@parent.nil?  
        @breadcrumbs = [["#{@comment.parent_type.pluralize}", send("#{@parent.class.name.downcase}s_path")], 
        [@comment.parent_name, @comment.parent], ["#{t(:comments)}(#{@comment.body})"]]
      end  
    end

    def new_breadcrumbs
      if !@parent.nil?
        @breadcrumbs = [["#{@parent.class.name.pluralize}", send("#{@parent.class.name.downcase}s_path")], 
        [@parent.parent_name, @parent], ["#{t(:new)} #{t(:comment)}"]]
      end  
    end

end
