# -*- coding: utf-8 -*-
class SubmissionsController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_submission, only: [:show, :edit, :update, :destroy]
  before_action :set_feedback, only: [:show]
  before_action :set_student
  before_action :set_exercise
  before_action :set_subject
  before_action :set_lecture

  # Permissions
  before_action :require_permission_index, only: [:index, :index_student, :index_tutorial, :index_exercise]
  before_action :require_permission_show, only: [:show]
  before_action :require_permission_create, only: [:new, :create]
  before_action :require_permission_edit, only: [:edit, :update]
  before_action :require_permission_destroy, only: [:destroy]
  before_action :submission_allowed?, only: [:new, :create, :edit, :update]
  before_action :lecture_closed, only: [:new, :create, :edit, :update, :destroy]
  
  # Actions (Resources)

  # Situational Indexing
  def index
    if params[:student_id].present?
      index_student #TODO
    elsif params[:exercise_id].present?
      index_exercise
    end
  end

  def missing #index
    if params[:student_id].present?
      index_student #TODO
    elsif params[:exercise_id].present?
      index_exercise_missing
    end
  end

  def external #index
    if params[:student_id].present?
      index_student #TODO
    elsif params[:exercise_id].present?
      index_exercise_external
    end
  end

	# TODO
	# This is designed for future implementation.
	# There is no submission index per student yet.
  def index_student
    @student = Student.find(params[:student_id])
    if current_user.get_role(@lecture) == @student
      @submissions = @student.submissions.decorate
      render 'submissions/index_student'
    elsif current_user.is_tutor?(@lecture) or
         current_user.is_tearcher(@lecture)
      @submissions = SubmissionDecorator.decorate_collection(@student.submissions.visible)
      render 'submissions/index_student'
    else
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_to @lecture
    end
  end

  def index_exercise
    @exercise = Exercise.find(params[:exercise_id]).decorate
    if current_user.is_teacher?(@lecture)
      respond_to do |format|
        format.html { render 'submissions/index_exercise' }
        format.json { render json: ::SubmissionsDatatable.new(@exercise, view_context) }
      end
    elsif current_user.is_tutor?(@lecture)
      @tutorial = current_user.get_tutor(@lecture).tutorial
      respond_to do |format|
        format.html { render 'submissions/index_exercise' }
        format.json { render json: ::SubmissionsDatatable.new(@exercise, view_context, @tutorial) }
      end
    else
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_to @lecture
    end
  end

  def index_exercise_missing
    @exercise = Exercise.find(params[:exercise_id]).decorate
    if current_user.is_teacher?(@lecture)
      respond_to do |format|
        format.html { render 'submissions/index_missing_exercise' }
        format.json { render json: ::NoSubmissionStudentsDatatable.new(@exercise, view_context) }
      end
    elsif current_user.is_tutor?(@lecture)
      @tutorial = current_user.get_tutor(@lecture).tutorial
      respond_to do |format|
        format.html { render 'submissions/index_missing_exercise' }
        format.json { render json: ::NoSubmissionStudentsDatatable.new(@exercise, view_context, @tutorial) }
      end
    else
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_to @lecture
    end
  end

  def index_exercise_external
    @exercise = Exercise.find(params[:exercise_id]).decorate
    if current_user.is_teacher?(@lecture)
      respond_to do |format|
        format.html { render 'submissions/index_external_exercise' }
        format.json { render json: ::ExternalSubmissionsDatatable.new(@exercise, view_context) }
      end
    else
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_to @lecture
    end
  end
  
  def show
  end

  def new
    @submission = @exercise.submissions.build
  end

  def edit
  end

  def create
    @submission = @exercise.submissions.build(submission_params)
    @submission.student = current_user.get_student(@lecture)

    if @submission.save
      if params[:save]
        flash[:notice] = trl("Ihre Eingabe wurde gespeichert.")
        redirect_to edit_submission_path(@submission)
      elsif params[:submit]
        @submission.update_attribute(:is_visible, true)
        flash[:notice] = trl("Ihre Eingabe wurde eingereicht. Eine Bearbeitung ist nicht mehr möglich.")
        redirect_to lecture_subjects_path(@lecture)
      else
        flash[:notice] = trl("Ihre Eingabe wurde gespeichert.")
        redirect_to lecture_subjects_path(@lecture)
      end
    else
      flash[:alert] = trl("Ihre Eingabe konnte nicht gespeichert werden.")
      render action: 'new'
    end
  end

  def update
    if @submission.update(submission_params)
      if params[:save]
        flash[:notice] = trl("Ihre Eingabe wurde gespeichert.")
        redirect_to edit_submission_path(@submission)
      elsif params[:submit]
        @submission.update_attribute(:is_visible, true)
        flash[:notice] = trl("Ihre Eingabe wurde eingereicht. Eine Bearbeitung ist nicht mehr möglich.")
        redirect_to lecture_subjects_path(@lecture)
      else
        flash[:notice] = trl("Ihre Eingabe wurde gespeichert.")
        redirect_to lecture_subjects_path(@lecture)
      end
    else
      flash[:alert] = trl("Ihre Eingabe konnte nicht gespeichert werden.")
      render action: 'edit'
    end
  end

  def destroy
    @submission.destroy
    redirect_to lecture_subjects_path(@lecture)
  end

  # ---

  private

	# ---

  # Strong Parameters

  def submission_params
    params.require(:submission).permit(:text, :is_visible, :comment)
  end

  # Variables

  def set_submission
    @submission = Submission.find(params[:id]).decorate
  end

  def set_student
    if params[:student_id]
      @student = Role.find(params[:student_id]).decorate
    end
  end

  def set_feedback
    unless @submission.feedback.nil?
      @feedback = @submission.feedback
    else
      @feedback = nil
    end
  end

  def set_exercise
    if params[:exercise_id]
      @exercise = Exercise.find(params[:exercise_id]).decorate
    elsif @submission
      @exercise = @submission.exercise
    end
  end

  def set_subject
    unless @exercise.nil?
      @subject = @exercise.subject
    end
  end

  def set_lecture
    unless @subject.nil?
      @lecture = @subject.lecture
    end
    unless @student.nil?
      @lecture = @student.lecture
    end
  end

  # Filters

  def require_login
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    else
      unless current_user.has_role?(@lecture)
        flash[:alert] = trl("Sie müssen diesem Kurs zugeordnet sein, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def submission_allowed?
    unless @subject.submission_allowed? or
           current_user.is_teacher_or_tutor?(@lecture)
      flash[:alert] = trl("Sie können diese Eingabe nicht mehr erstellen/bearbeiten/löschen. Der Abgabezeitpunkt ist überschritten.")
      redirect_back_or root_path
    end
  end

  def require_permission_index
    require_login
  end

  def require_permission_show
    unless require_login
      unless current_user.is_teacher_or_tutor?(@lecture) or
            @submission.student.user == current_user or
						flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def require_permission_edit
    unless require_login
      unless current_user.is_teacher_or_tutor?(@lecture) or
            current_user == @submission.student.user
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def require_permission_create
    unless require_login
      submission_allowed?
    end
  end

  def require_permission_destroy
    unless require_login
      unless submission_allowed?
        unless @submission.feedback.nil?
          flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Eingabe zu löschen. Es existiert ein Feedback.")
          redirect_back_or root_path
        end
      end
    end
  end

  def lecture_closed
    if @lecture and @lecture.closed
      flash[:alert] = trl("Der Kurs ist zur Bearbeitung geschlossen. Die Aktion konnte nicht durchgeführt werden.")
      redirect_back_or lecture_path(@lecture)
    end
  end

end
