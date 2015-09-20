class TutorialDecorator < ApplicationDecorator

  # Delegations

  delegate_all

  # Associations

  decorates_association :lecture
  decorates_association :tutor

  # Methods

  def name
    return object.tutor.decorate.list_name unless object.tutor.nil?
    return "Tutorium Nr. " + self.id.to_s
  end

  def members
    string = self.valid_students.count.to_s
    string + " / " + self.max_students.to_s unless self.max_students.nil?
  end

end
