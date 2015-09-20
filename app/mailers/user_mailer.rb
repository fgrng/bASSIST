class UserMailer < ActionMailer::Base

  def password_reset(user)
    @user = user
    mail :to => @user.email, :subject => "[bASSIST] Neues Passwort setzen"
  end

  def email_validation(user)
    @user = user
    mail :to => @user.email, :subject => "[bASSIST] Email-Adresse verifizieren"
  end

  def data_verified(student)
    @student = student
    @user = student.user
    @lecture = student.lecture
    mail :to => @user.email, :subject => "[bASSIST] Daten validiert"
  end

	# TODO
  def feedback(feedback)
    @submission = feedback.submission
    @user = @submission.student.user
    @subject = @submission.exercise.subject
    mail :to => @user.email, :subect => "[bASSIST] Feedback erhalten"
  end
  
end
