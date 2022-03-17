# -*- coding: utf-8 -*-
class FeedbacksController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_feedback, except: [:new, :create]
  before_action :set_submission
  before_action :set_exercise
  before_action :set_subject
  before_action :set_lecture

  # Permissions
  before_action :require_permission_show, only: [:show]
  before_action :require_permission_create, only: [:new, :create]
  before_action :require_permission_edit, only: [:edit, :update, :destroy]
  before_action :lecture_closed, except: [:show]
  
  # Actions (Resources)

  def show
  end

  def new
    @feedback = @submission.build_feedback
  end

  def edit
  end

  def create
    @feedback = @submission.build_feedback(feedback_params)
    if @feedback.save
      if params[:save]
        flash[:notice] = trl("Ihr Feedback wurde gespeichert.")
        redirect_to edit_feedback_path(@feedback)
      elsif params[:exit]
        flash[:notice] = trl("Ihr Feedback wurde gespeichert.")
        redirect_to exercise_submissions_path(@exercise)
      elsif params[:publish]
        # Quickly update visibility, validations already run at @feedback.save above.
        @feedback.update_attribute(:is_visible, true)
        flash[:notice] = trl("Ihr Feedback wurde gespeichert und veröffentlicht.")
        redirect_to exercise_submissions_path(@exercise)
      else
        flash[:notice] = trl("Ihr Feedback wurde gespeichert.")
        redirect_to lecture_subjects_path(@lecture)
      end
    else
      render action: 'new'
    end
  end

  def update
    if @feedback.update(feedback_params)
      if params[:save]
        flash[:notice] = trl("Ihr Feedback wurde gespeichert.")
        redirect_to edit_feedback_path(@feedback)
      elsif params[:exit]
        flash[:notice] = trl("Ihr Feedback wurde gespeichert.")
        redirect_to exercise_submissions_path(@exercise)
      elsif params[:publish]
        # Quickly update visibility, validations already run at @feedback.update(…) above.
        @feedback.update_attribute(:is_visible, true)
        flash[:notice] = trl("Ihr Feedback wurde gespeichert und veröffentlicht.")
        redirect_to exercise_submissions_path(@exercise)
      else
        flash[:notice] = trl("Ihr Feedback wurde gespeichert.")
        redirect_to exercise_submissions_path(@exercise)
      end
    else
      render action: 'edit'
    end
  end

  def destroy
    @feedback.destroy
    redirect_to exercise_submissions_path(@exercise)
  end

  # Actions (Visibility Button)

  def toggle_public
    if @feedback.is_visible
      @feedback.update_attribute(:is_visible, false)
      flash[:notice] = trl("Ihr Feedback ist nicht veröffentlicht.")
    else
      @feedback.update_attribute(:is_visible, true)
      # @feedback.mail_notification
      flash[:notice] = trl("Ihr Feedback ist veröffentlicht.")
    end
    redirect_to exercise_submissions_path(@exercise)
  end

  # ---

  private

	# ---

  # Variables
  
  def set_feedback
    @feedback = Feedback.find(params[:id]).decorate
  end

  def set_submission
    if params[:submission_id]
      @submission = Submission.find(params[:submission_id]).decorate
    else
      @submission = @feedback.submission
    end
  end

  def set_exercise
    @exercise = @submission.exercise
  end

  def set_subject
    @subject = @exercise.subject
  end

  def set_lecture
    @lecture = @subject.lecture
  end

  # Strong Parameters

  def feedback_params
    params.require(:feedback).permit(:text,
                                     :passed,
                                     :is_visible,
                                     :grade)
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

  def require_permission_index
    require_login
    unless current_user.is_teacher_or_tutor(@lecture)
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def require_permission_show
    require_login
    unless @submission.student.user == current_user or
           current_user.is_teacher_or_tutor?(@lecture)
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def require_permission_create
    require_login
    unless current_user.is_teacher_or_tutor?(@lecture)
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def require_permission_edit
    require_login
    unless current_user.is_teacher_or_tutor?(@lecture)
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def lecture_closed
    if @lecture and @lecture.closed
      flash[:alert] = trl("Der Kurs ist zur Bearbeitung geschlossen. Die Aktion konnte nicht durchgeführt werden.")
      redirect_back_or lecture_path(@lecture)
    end
  end
  
end
