class PostsController < ApplicationController
  helper :users

  before_filter :handle_breadcrumbs
  before_filter :check_permissions

  def index
    #puts "THREAD OUTPUT_______________________________"
    #p @thread
    @posts   = Post.includes(:user).where(:rope_id => @rope.id).page(params[:page]).per(@user.per_page(:posts))
  end

  def new
    return render "error/400" unless can?(:post, @rope)
    @post = Post.new
    @post.parent_id = params[:parent_id] if params[:parent_id]
  end

  def create
    return render "error/400" unless can?(:post, @rope)
    @post = Post.create params[:post]
    @post.rope = @rope
    @post.user = @user
    unless @post.save
      render "new"
    else
      redirect_to board_rope_posts_path(@post.rope.board.id, @post.rope.id, \
                                        :page => @post.page(@user.per_page(:posts)),
                                        :anchor => "post-#{@post.id}"
                                      ) unless request.xhr?
    end
  end

  def show
    @post = Post.find params[:id]
  end

  def edit
    @post = Post.find params[:id]
    return render "error/400" unless can?(:edit_post, @rope) or (@post.user == @user and can?(:edit_own_post, @rope))
  end

  def update
    @post = Post.find params[:id]
    return render "error/400" unless can?(:edit_post, @rope) or (@post.user == @user and can?(:edit_own_post, @rope))
    @post.body   = params[:post][:body]
    @post.format = params[:post][:format]
    unless @post.save
      render "update"
    else
      redirect_to board_rope_posts_path(@post.rope.board.id, @post.rope.id, \
                                        :page => @post.page(@user.per_page(:posts)),
                                        :anchor => "post-#{@post.id}"
                                      ) unless request.xhr?
    end
  end

  def destroy
    @post = Post.find params[:id]
    return render "error/400" unless can?(:delete_post, @rope) or (@post.user == @user and can?(:edit_own_post, @rope))
    @post.destroy
    redirect_to board_rope_posts_path(@post.rope.board_id, @post.rope.id)
  end

  protected

  def handle_breadcrumbs
    @board   = Board.find(params[:board_id])
    @rope    = Rope.find(params[:rope_id])
    @breadcrumbs.add :name => @board.name, :link => url_for(@board)
    @breadcrumbs.add :name => @rope.title, :link => url_for([@board, @rope])
  end

  def check_permissions
    render 'error/400' unless can? :read, @board
    render 'error/400' unless can? :read, @rope
  end
end
