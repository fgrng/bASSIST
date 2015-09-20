# coding: utf-8
class UsersController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # Permissions
  before_action :require_login, except: [:index, :new, :create]
  before_action :require_assistant, only: [:index, :destroy]

  # Actions (Resources)

  def index
    respond_to do |format|
      format.html
      format.json { render json: ::UsersDatatable.new(view_context) }
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = trl('Benutzer wurde erfolgreich angelegt. Um Ihren Account freizuschalten verifizieren Sie bitte Ihre Email-Adresse.')
      redirect_to signin_path
    else
      render action: 'new'
    end
  end

  def update
    if @user.update(user_params)
      flash[:notice] = trl('Benutzerdaten wurden erfolgreich aktualisiert.')
      redirect_to @user
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url
  end

  # ---

  private

	# ---

  # Variables

  def set_user
    @user = User.find(params[:id]).decorate
  end

  # Strong Parameters

  def user_params
    params.require(:user).permit(:email,
                                 :first_name,
                                 :last_name,
                                 :password,
                                 :password_confirmation)
  end

  def require_login
    unless signed_in? and current_user.id == @user.id
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

end
