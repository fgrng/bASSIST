class UserDecorator < ApplicationDecorator

  # Delegations

  delegate_all

  # Methods

  def full_name
    object.first_name + " " + object.last_name
  end

  def list_name
    object.last_name + ", " + object.first_name
  end

  def
    email_raw
  end

  def email_link
    h.mail_to object.email, object.email, subject: '[bASSIST] '
  end

  def email_raw
    object.email
  end
  
  def email_full_name
    h.mail_to object.email, self.full_name, subject: '[bASSIST] '
  end

  def email_list_name
    h.mail_to object.email, self.list_name, subject: '[bASSIST] '
  end
  
  def dt_list_name
    h.render(
      :partial => 'roles/index/students_info_button',
      :formats => :html,
      :locals => {:name => list_name,
                  :email => email_raw })
  end

end
