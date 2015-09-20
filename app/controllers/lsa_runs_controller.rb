# coding: utf-8
class LsaRunsController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_type
  before_action :set_lecture

  # Permissions
  before_action :require_permission, only: [:index, :show]
  before_action :require_permission_new, only: [:new, :create]
  before_action :require_permission_destroy, only: [:destroy]
  
  # Actions (Resources)

  def index
    respond_to do |format|
      format.html { }
      format.json { render json: ::LsaRunsDatatable.new(@lecture, view_context) }
    end
  end

  def show
  end

  def new
    respond_to do |format|
			format.html { 
				@lsa_run = type_class.new
				render "new_#{type_class.to_s.underscore}"
			}
    end
	end

  def create
    case type
    when LsaRun::TYPE_SORTING
      @run = LsaSortingRun.new
			run_param = LsaRun::TYPE_SORTING.underscore
    when LsaRun::TYPE_PLAGIARISM
      @run = LsaPlagiarismRun.new
			run_param = LsaRun::TYPE_PLAGIARISM.underscore
    when LsaRun::TYPE_SCORING
      @run = LsaScoringRun.new
			run_param = LsaRun::TYPE_SCORING.underscore
    end

    # Basic LsaRun
    @run.lecture = @lecture
    @run.user = current_user
    @run.error_message = LsaRun::STATUS_PLANNED

    schedule_time = Time.new(params[run_param]["schedule_time(1i)"].to_i, 
														 params[run_param]["schedule_time(2i)"].to_i,
														 params[run_param]["schedule_time(3i)"].to_i,
														 params[run_param]["schedule_time(4i)"].to_i,
														 params[run_param]["schedule_time(5i)"].to_i)
    @run.schedule_time = schedule_time

    lsa_server = LsaServer.find(params[run_param][:lsa_server_id])
    @run.lsa_server = lsa_server

		lsa_user = User.find(params[run_param]["user_id"])
		@run.user = lsa_user
    
    if @run.save
      # Specific LsaRun
      case type
      when LsaRun::TYPE_SORTING
        exercise = Exercise.find(params[run_param][:exercise_id])
        @run.exercise = exercise
        @run.ideal_solution = exercise.ideal_solution
      when LsaRun::TYPE_SCORING
        exercise = Exercise.find(params[run_param][:exercise_id])
        @run.exercise = exercise
        @run.ideal_solution = exercise.ideal_solution
        @run.first_scored_text = params[run_param][:first_scored_text]
        @run.first_text_score = params[run_param][:first_text_score]
        @run.second_scored_text = params[run_param][:second_scored_text]
        @run.second_text_score = params[run_param][:second_text_score]
      when LsaRun::TYPE_PLAGIARISM
        params[run_param][:exercise_ids].each do |id|
          unless id.nil? or id.empty?
            ex = Exercise.find_by_id(id)
            @run.exercises << ex unless ex.nil?
          end
        end
      end
      # Specific LsaRun End
      if @run.save
        @run.start_standard
        flash[:notice] = trl("Der Prozess wurde erfolgreich gestartet.")
        redirect_to lecture_path(@lecture)
      else
        flash[:error] = trl("Bei der Bearbeitung Ihrer Anfrage ist ein Fehler aufgetreten.")
        redirect_to lecture_path(@lecture)
      end
    else
      flash[:error] = trl("Bei der Bearbeitung Ihrer Anfrage ist ein Fehler aufgetreten.")
      redirect_to lecture_path(@lecture)
    end
  end
  
  def destroy
    @run = LsaRun.find_by_id(params[:id])
    @run.destroy
    flash[:notice] = trl("LsaRun erfolgreich gelöscht.")
    redirect_to lsa_runs_url      
  end

  # ---
  
  private

	# ---

  # Single Table Inheritance

  def type 
    params[:type] || "LsaRun"
  end

  def type_class 
    type.constantize 
  end

  def type_scope
    type.underscore.pluralize
  end

  # Variables

  def set_type
    @type = type
  end

  def set_lsa_run
    @lsa_run = type_class.find(params[:id]).decorate
  end

  def set_lecture
    if params[:lecture_id]
      @lecture = Lecture.find(params[:lecture_id]).decorate
    elsif !(@exercise.nil?)
      @lecture = @exercise.subject.lecture
    else
      @lecture = nil # TODO
    end
  end

  # Permissions

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

  def require_permission_new
    unless require_login
      unless current_user.is_teacher_or_tutor?(@lecture)
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def require_permission_destroy
    unless require_login
      unless current_user.is_assistant?
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

end


