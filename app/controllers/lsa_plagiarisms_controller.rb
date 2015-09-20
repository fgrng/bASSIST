# coding: utf-8
class LsaPlagiarismsController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_lsa_run, only: [:index]
  before_action :set_plagiarism, only: [:show]

  # Permissions
  before_action :require_permission, only: [:index, :show]
  
  # Actions (Resources)

  def show
  end

	def update
		@lsa_plagiarism = LsaPlagiarism.find(params[:id])
		if @lsa_plagiarism.update(lsa_plagiarism_params)
      flash[:notice] = trl('Status erfolgreich eingetragen.')
      redirect_to lsa_plagiarism_run_lsa_plagiarisms_path(@lsa_plagiarism.lsa_run)
		else
			flash[:notice] = '.'
			redirect_to @lsa_plagiarism
		end
	end

  def index
    respond_to do |format|
      format.html {
        # @plagiarisms = @lsa_run.lsa_plagiarisms.ordered
      }
      format.json {
        render json: ::LsaPlagiarismsDatatable.new(@lsa_run, view_context)
      }
    end
  end

  # ---

  private

	# ---

  # Strong Parameters
	
  def lsa_plagiarism_params
    params.require(:lsa_plagiarism).permit(:watched)
  end

  # Variables

  def set_lsa_run
    if params[:lsa_plagiarism_run_id]
      @lsa_run = LsaRun.find(params[:lsa_plagiarism_run_id]).decorate
			@lecture = @lsa_run.lecture.decorate
    else
      # TODO
      @lsa_run = nil
    end
  end

  def set_plagiarism
    @plagiarism = LsaPlagiarism.find(params[:id]).decorate

    @submission_a = @plagiarism.submission_a.decorate
		@lsa_passage_collection_a = @plagiarism.lsa_passage_collection_a.decorate

    @submission_b = @plagiarism.submission_b.decorate
		@lsa_passage_collection_b = @plagiarism.lsa_passage_collection_b.decorate
  end
  
  # Filters

  def require_login
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def require_permission
    unless require_login
      unless current_user.is_assistant or current_user.has_tutor? or current_user.has_teacher?
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

end
