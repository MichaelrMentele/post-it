class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update]

  def index
    @posts = Post.all
  end

  def show
    @comments = @post.comments
    @comment = Comment.new
  end

  def new 
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.creator = User.first # TODO: CHange to logged in user

    if @post.save
      flash[:notice] = "Post was created."
      redirect_to posts_path
    else
      render 'new'
    end
  end

  def edit; end

  def update

    if @post.update(post_params)
      flash[:notice] = "this post was updated."
      redirect_to post_path(@path)
    else
      render "/posts/show"
    end
        
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit!
  end
end
