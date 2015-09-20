# coding: utf-8
class ExercisesController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_exercise, except: [:new, :index, :create, :create_empty_sub]
  before_action :set_type, only: [:show, :edit, :update, :destroy, :create_empty_sub]
  before_action :set_subject, except: [:create_empty_sub]
  before_action :set_lecture, except: [:create_empty_sub]
  
  # Permissions
  before_action :require_permission, except: [:index, :show, :create_empty_sub, :create_extra_sub, :create_empty_sub, :count_submissions]
  before_action :require_permission_tutor, only: [:create_empty_sub, :count_submissions]
  before_action :lecture_closed, except: [:index, :show, :count_submissions, :create_empty_sub]
  
  # Actions (Resources)

  def index
    @exercises = @subject.send(type_scope).decorate
  end

  def show
    respond_to do |format|
      format.html { }
      format.json { render :json => @exercise.as_json }
    end		
  end

  def new
    @exercise = type_class.new
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      flash[:notice] = trl("#{type} wurde erfolgreich aktualisiert.")
      redirect_to lecture_subjects_path(@lecture)
    else
      render :action => 'edit'
    end
  end

  def create
    @exercise = @subject.send(type_scope).build(exercise_params)
    if @exercise.save
      flash[:notice] = trl("#{type} wurde erfolgreich angelegt.")
      redirect_to lecture_subjects_path(@lecture)
    else
      render :action => 'new'
    end
  end

  def destroy
    @exercise.destroy
    redirect_to lecture_subjects_path(@lecture)
  end

  # Actions (Manage special Submissions)

  def create_empty_sub
    # Current user signed in?
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end

    exercise = Exercise.find(params[:id])
    student = Student.find(params[:student_id])

    # Student is registered in Lecture?
    unless student.lecture == exercise.subject.lecture
      flash[:alert] = trl("Die Aktion konnte nicht ausgeführt werden.")
      redirect_back_or root_path
    end

    @lecture = student.lecture
    lecture_closed    
    
    # Current user has permission?
    unless current_user.is_tutor?(@lecture) or
          current_user.is_teacher?(@lecture)
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion durchzuführen.")
      redirect_back_or @lecture
    end

    # Setup new Submission
    submission = Submission.new
    submission.exercise = exercise
    submission.student = student

    if submission.save
      flash[:notice] = trl("Leere Abgabe wurde angelegt für #{student.decorate.full_name}.")
      redirect_to edit_submission_path(submission)
    else
      flash[:alert] = trl("Leere Abgabe konnte nicht angelegt werden.")
      redirect_back_or lecture_subjects_path(@lecture)
    end
  end

  def create_extra_sub
    # Current user signed in?
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end

    exercise = Exercise.find(params[:id])
    lecture = exercise.subject.lecture

    # Current user has permission?
    unless current_user.is_teacher?(lecture)
      flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion durchzuführen.")
      redirect_back_or lecture
    end

    # Setup new Submission
    submission = Submission.new
    submission.exercise = exercise
    submission.external = true

    if submission.save
      flash[:notice] = trl("Zusatzabgabe wurde angelegt.")
      redirect_to edit_submission_path(submission)
    else
      flash[:alert] = trl("Zusatzabgabe konnte nicht angelegt werden.")
      redirect_back_or lecture_subjects_path(lecture)
    end
  end

	# Actions (JSON API)

  def count_submissions
    respond_to do |format|
      format.json {
        if params[:count_tutorial]
          tutorial = Tutorial.find(params[:count_tutorial])
          total = tutorial.valid_students
          total = total.where(group_number: @exercise.group_number) if @exercise.group_number > 0
          render json: [
                   @exercise.submissions.where(student_id: tutorial.valid_students.select(:id)).visible.count,
                   total.count
                 ]
        else
          total = @exercise.subject.lecture.valid_students
          total = total.where(group_number: @exercise.group_number) if @exercise.group_number > 0
          render json: [
                   @exercise.submissions.visible.count,
                   total.count
                 ]
        end
      }
    end
  end

	def lsa_sorting_last
		respond_to do |format|
			format.json{
				run = LsaSortingRun.where(exercise_id: @exercise.id).last
				sortings = run.lsa_sortings.ordered.to_a
				percentile = (sortings.count / 10).to_i 
				first_sub = sortings[percentile].submission
				second_sub = sortings[-(percentile+1)].submission
				render json: { :first => first_sub, :second => second_sub, first_score: first_sub.grade, second_score: second_sub.grade }
			}
		end
	end

	# ---

  private

	# ---

  # Single Table Inheritance

  def type
    params[:type] || "Exercise"
  end

  def type_class
    type.constantize
  end

  def type_scope
    type.underscore.pluralize
  end

  # Set Variables

  def set_type
    @type = type
  end

  def set_exercise
    @exercise = type_class.find(params[:id]).decorate
  end

  def set_subject
    if params[:subject_id]
      @subject = Subject.find(params[:subject_id]).decorate
    else
      @subject = @exercise.subject
    end
  end

  def set_lecture
    @lecture = @subject.lecture
  end

  # Strong Parameters

  def exercise_params
    params.require(type.underscore.to_sym).permit(:text,
                                                  :min_points,
                                                  :max_points,
																									:group_number,
                                                  :ideal_solution)
  end

  # Filters

  def require_permission
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    else
      unless current_user.is_teacher?(@lecture)
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion durchzuführen.")
        redirect_back_or root_path
      end
    end
  end

  def require_permission_tutor
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    else
			@lecture ||= Exercise.find(params[:id]).subject.lecture
      unless current_user.is_teacher_or_tutor?(@lecture)
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion durchzuführen.")
        redirect_back_or root_path
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
