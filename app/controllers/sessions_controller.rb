# coding: utf-8
class SessionsController < ApplicationController

  # Actions (Resources)
  
  def new
  end

  def create
    user = User.verified.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      unless user.active_lecture_id.nil? or !(user.has_role?(user.active_lecture))
        redirect_to user.active_lecture
      else
        redirect_to lectures_path
      end
    else
      flash[:error] = trl("Die übertragene Email/Password Kombination ist nicht gültig.")
      redirect_back_or signin_path
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
