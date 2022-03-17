# coding: utf-8
class PasswordResetsController < ApplicationController

  # Actions (Resources)

  def new
  end

  def create
    user = User.find_by_email(params[:password_reset][:email].downcase)
    unless user.nil?
      user.send_password_reset
      redirect_to signin_path, :notice => "Eine Email mit weiteren Instruktionen wurde verschickt."
    else
      render :new, :notice => "Es wurde kein Nutzer mit dieser Email Adresse gefunden."
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Die Gültigkeit des Links ist abgelaufen."
    elsif @user.update(params[:user].permit(:password, :password_confirmation))
      # Rails 6.1 update: renamed "@user.update_attributes" to "@user.update"
      #   via Github Issue 5.
      redirect_to root_url, :notice => "Neues Passwort wurde gesetzt."
    else
      render :edit
    end
  end

end
