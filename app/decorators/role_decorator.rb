class RoleDecorator < ApplicationDecorator

  # Constants

  TYPE_NAMES = {
    Role::TYPE_STUDENT => "Student*in",
    Role::TYPE_TUTOR => "Tutor*in",
    Role::TYPE_TEACHER => "Dozent*in",
  }

  # Delagations

  delegate_all

  # Associations

  decorates_association :user
  decorates_association :lecture
 
  # Methods

  def full_name
    object.user.decorate.full_name
  end

  def list_name
    object.user.decorate.list_name
  end

  def email
    object.user.decorate.email
  end

  def email_raw
    object.user.decorate.email_raw
  end
  
  def email_full_name
    object.user.decorate.email_full_name
  end

  def email_list_name
    object.user.decorate.email_list_name
  end

  # Datatables

  def dt_list_name
    object.user.decorate.dt_list_name
  end

  def dt_tutorial_name
    return object.tutorial.decorate.name unless object.tutorial.nil?
    return "kein Tutorium"
  end

end
