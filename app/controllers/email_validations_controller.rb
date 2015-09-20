# coding: utf-8
class EmailValidationsController < ApplicationController

  def show
    @user = User.find_by_email_validation_token!(params[:id])

		# Email validation only valid von XX hours
		# (There is no method to resend validation email implemented yet.)
		#
    # if @user.email_validation_sent_at < 48.hours.ago
    #   redirect_to new_password_reset_path, :alert => "Die Gültigkeit des Links ist abgelaufen."
    # elsif

    if @user.verify
      redirect_to signin_path, :notice => "Ihr Account wurde freigeschaltet. Sie können sich nun anmelden."
    else
      redirect_to root_path, :alert => "Die Aktion konnte nicht durchgeführt werden."
    end
  end

end
