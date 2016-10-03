class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :vote]
  before_action :require_user, except: [:show, :index]
  before_action :require_permissions, only: [:edit, :update]
  def index
    @posts = Post.all.sort_by{|x| x.diff_votes}.reverse
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
    @post.creator = current_user

    if @post.save
      flash[:notice] = "Post was created."
      redirect_to posts_path
    else
      render 'new'
    end
  end

  def edit;  end

  def update
    if @post.update(post_params)
      flash[:notice] = "this post was updated."
      redirect_to post_path(@path)
    else
      render "/posts/show"
    end   
  end

  def vote
    @vote = Vote.create(voteable: @post, creator: current_user, vote: params[:vote])
    
    respond_to do |format|
      format.html do 
        if @vote.valid?
          flash[:notice] = "Your vote was counted."
        else
          flash[:error] = "You already voted"
        end
        redirect_to :back
      end
      format.js
    end    
  end

  private

  def set_post
    @post = Post.find_by slug: params[:id]
  end

  def post_params
    params.require(:post).permit!
  end

  def require_permissions
    user = current_user
    post = Post.find_by slug: params[:id]

    access_denied unless logged_in? and (current_user == post.creator || user.admin?)
  end
end
