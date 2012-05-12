class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]

  def new
    @user = User.new
  end

  def index
    @users = User.paginate(per_page: 15, page: params[:page])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      sign_in(@user)
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in(@user)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user_to_delete = User.find(params[:id])
    if not current_user.admin? or current_user?(user_to_delete) or user_to_delete.admin?
      redirect_to root_path
    else
      user_to_delete.destroy
      flash[:success] = "User destroyed"
      redirect_to users_path
    end

  end

  private
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, notice: "Please sign in"
    end
  end
end
