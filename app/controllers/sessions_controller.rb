# coding: utf-8
class SessionsController < ApplicationController

  # Actions (Resources)
  
  def new
  end

  def create
    # find user
    user = User.signin_find(params[:session][:email])

    unless user.present?
      # User does not exist
      flash[:error] = trl("Die übertragene Email/Password Kombination ist nicht gültig.")
      redirect_back_or signin_path
    else
      unless user.validated
        # User email address not validated
        flash[:error] = trl("Die angegebene Email-Adresse wurde noch nicht verifiziert.")
        redirect_back_or signin_path
      else
        if user.authenticate(params[:session][:password])
          # Correct password! Sign in.
          sign_in user
          unless user.active_lecture.nil? or !(user.has_role?(user.active_lecture))
            # User has already visited a lecture.
            redirect_to user.active_lecture
          else
            # User never visited a lecture.
            redirect_to lectures_path
          end
        else
          # Password not correct.
          flash[:error] = trl("Die übertragene Email/Password Kombination ist nicht gültig.")
          redirect_back_or signin_path
        end
      end
    end
  end

  def destroy
    sign_out if signed_in?
    redirect_to root_path
  end

  private

  def check_params_signin
    unless params[:session].present? and
          params[:session][:email].present? and
          params[:session][:password].present?
      flash[:danger] = trl("Bei der Übertragung Ihrer Eingaben ist ein Fehler aufgetreten. Bitte versuchen sie es erneut.")
      redirect_back_or signin_path
    end
  end

end
