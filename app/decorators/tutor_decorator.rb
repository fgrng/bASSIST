class TutorDecorator < RoleDecorator

  # Delegations
  delegate_all

  # Associations
  decorates_association :tutorial

end
