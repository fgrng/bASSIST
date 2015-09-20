class LsaPlagiarismRunDecorator < LsaRunDecorator
  
  # Methods

  def dt_target
    h.render(
      :partial => 'lsa_runs/index/lsa_plagiarism_run_target_button',
      :formats => :html,
      :locals => {:exercises => object.exercises }
    )
  end
  
  def dt_results
    h.render(
      :partial => 'lsa_runs/index/lsa_plagiarism_run_results_button',
      :formats => :html,
      :locals => { :run => object }
    )
  end

end
