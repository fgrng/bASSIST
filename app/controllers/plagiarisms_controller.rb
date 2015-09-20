class PlagiarismsController < ApplicationController

  # Filters

  # Variables
  before_action :set_plagiarism

  # Actions (Resources)

  def show
  end

  # ---

  private

	# ---

  # Variables

  def set_plagiarism
    @plagiarism = Plagiarism.find(params[:id]).decorate
    @submission = @plagiarism.submission
    @source = @plagiarism.source
    @exercise = @plagiarism.exercise
  end

end
