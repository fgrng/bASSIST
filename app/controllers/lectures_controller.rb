# coding: utf-8
class LecturesController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_lecture, except: [:index, :new, :create]

  # Permissions
  before_action :require_permission, except: [:create, :destroy, :index, :new, :show]
  before_action :require_assistant, only: [:create, :destroy]
  before_action :lecture_closed, only: [:add, :add_group, :remove_group, :fill_groups, :clear_groups,
                                        :clear_tutorials, :fill_tutorials, :refill_tutorials,
                                        :force_fill_tutorials, :force_refill_tutorials,
                                        :assign_tutorials, :deassign_tutorails, :destroy]
  
  # Actions (Resources)

  # Situational Indexing
  def index
    deselect_lecture
    if signed_in? and ( current_user.is_admin or current_user.is_assistant )
      index_assistant
    else
      index_others
    end
  end

  def index_assistant
    @lectures = Lecture.all.order(created_at: :desc).decorate
    render 'lectures/index_assistant'
  end

  def index_others
    @lectures = Lecture.recent.order(created_at: :desc).decorate
    render 'lectures/index'
  end

  def show
    select_lecture @lecture
  end

  def new
    @lecture = Lecture.new
  end

  def edit
  end

  def create
    @lecture = Lecture.new(lecture_params)
    if @lecture.save
      flash[:notice] = trl('Kurs wurde erfolgreich angelegt.')
      redirect_to @lecture
    else
      render action: 'new'
    end
  end

  def update
    if @lecture.update(lecture_params)
      flash[:notice] = trl('Kurs wurde erfolgreich aktualisiert.')
      redirect_to @lecture
    else
      render action: 'edit'
    end
  end

  def destroy
    @lecture.destroy
    redirect_to lectures_url
  end

  # Actions (Data Export)

  def export_subjects
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="' + @lecture.filebasename + "-submissions" + '.xml"'
        render 'lectures/export_subjects'
      }
    end
  end

  def export_students
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="' + @lecture.filebasename + "-students" + '.xml"'
        render 'lectures/export_students'
      }
    end
  end

  # Actions (Role Management)

  def add
    user = User.find(params[:user_id])
    lecture = Lecture.find(params[:id])
    student = Student.new
    student.user = user
    student.lecture = lecture
    if student.save
      flash[:notice] = trl('Student erfolgreich hinzugefügt.')
      redirect_to users_url
    else
      flash[:alert] = trl('Student wurde nicht hinzugefügt.')
      redirect_to users_url                      
    end
  end

  # Actions (Group Management)

  def add_group
    @lecture.add_group
    redirect_to @lecture
  end

  def remove_group
    @lecture.remove_group
    redirect_to @lecture
  end

  def fill_groups
    @lecture.fill_groups
    redirect_to lecture_students_path(@lecture)
  end

  def clear_groups
    @lecture.clear_groups
    redirect_to lecture_students_path(@lecture)
  end

  # Actions (Tutorial Management)

  def clear_tutorials
    @lecture.clear_tutorials
    redirect_to lecture_tutorials_path(@lecture)
  end

  def fill_tutorials
    @lecture.fill_tutorials
    redirect_to lecture_tutorials_path(@lecture)
  end

  def refill_tutorials
    @lecture.refill_tutorials
    redirect_to lecture_tutorials_path(@lecture)
  end

  def force_fill_tutorials
    @lecture.force_fill_tutorials
    redirect_to lecture_tutorials_path(@lecture)
  end

  def force_refill_tutorials
    @lecture.force_refill_tutorials
    redirect_to lecture_tutorials_path(@lecture)
  end

  def assign_tutorials
    @lecture.assign_tutorials
    flash[:notice] = trl("Freie Tutorien wurden zugeordnet.")
    redirect_to lecture_tutors_path(@lecture)
  end

  def deassign_tutorials
    @lecture.deassign_tutorials
    flash[:notice] = trl("Zuordnung der Tutorien wurde aufgehoben.")
    redirect_to lecture_tutors_path(@lecture)
  end

  # ---

  private

	# ---

  # Variables

  def set_lecture
    @lecture = Lecture.find(params[:id]).decorate
  end

  # Strong Parameters

  def lecture_params
    params.require(:lecture).permit(:name,
                                    :year,
                                    :term,
                                    :description,
                                    :teacher,
                                    :statement_name,
                                    :a_statement_name,
                                    :b_statement_name,
                                    :c_statement_name,
                                    :reflection_name,
                                    :a_reflection_name,
                                    :b_reflection_name,
                                    :c_reflection_name,
                                    :register_start,
                                    :register_stop,
                                    :closed,
                                    :teacher_key,
                                    :tutor_key,
                                    :is_visible)
  end

  # Filters

  def require_permission
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    else
      set_lecture
      unless current_user.is_assistant or current_user.is_admin or current_user.is_teacher?(@lecture)
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def lecture_closed
    if @lecture.closed
      flash[:alert] = trl("Der Kurs ist zur Bearbeitung geschlossen. Die Aktion konnte nicht durchgeführt werden.")
      redirect_back_or lecture_path(@lecture)
    end
  end

end
