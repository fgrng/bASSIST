class SubjectDecorator < ApplicationDecorator

  # Delegations
  delegate_all

  # Associations
  decorates_association :lecture

end
