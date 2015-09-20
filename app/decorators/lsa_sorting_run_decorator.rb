class LsaSortingRunDecorator < LsaRunDecorator
  
  # Associations

  decorates_association :exercise
  
  # Methods

  def dt_target
    h.render(
      :partial => 'lsa_runs/index/lsa_plagiarism_run_target_button',
      :formats => :html,
      :locals => {:exercises => [object.exercise] }
    )
  end
  
  def dt_results
    LsaRun::STATUS_DONE
  end

end
