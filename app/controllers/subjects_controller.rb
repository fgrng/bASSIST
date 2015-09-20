# coding: utf-8
class SubjectsController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_subject, only: [:show, :edit, :update, :destroy]
  before_action :set_lecture

  # Permissions
  before_action :require_login
  before_action :require_permission, except: [:index, :show]
  before_action :lecture_closed, except: [:index, :show]

  # Actions (Resources)

  def index
    if current_user.is_tutor_or_teacher?(@lecture)
      @subjects = @lecture.subjects
    else
      @subjects = @lecture.subjects.visible
    end
  end

  def show
  end

  def new
    @subject = @lecture.subjects.build
    @lsa_servers = LsaServer.all
  end

  def edit
    @lsa_servers = LsaServer.all
  end

  def create
    @subject = @lecture.subjects.build(subject_params)

    if @subject.save
      flash[:notice] = trl('Themengebiet wurde erfolgreich angelegt.')
      redirect_to lecture_subjects_path(@lecture)
    else
      render action: 'new'
    end
  end

  def update
    if @subject.update(subject_params)
      flash[:notice] = trl('Themengebiet wurde erfolgreich aktualisiert.')
      redirect_to lecture_subjects_path(@lecture)
    else
      render action: 'edit'
    end
  end

  def destroy
    @subject.destroy
    flash[:notice] = trl('Themengebiet wurde erfolgreich aktualisiert.')
    redirect_to lecture_subjects_path(@lecture)
  end

  # ---

  private

	# ---

  # Strong Parameters

  def subject_params
    params.require(:subject).permit(:name, :due_date, :start_date, :lsa_server_id)
  end

  # Variables

  def set_subject
    @subject = Subject.find(params[:id]).decorate
  end

  def set_lecture
    if params[:lecture_id]
      @lecture = Lecture.find(params[:lecture_id]).decorate
    else
      @lecture = @subject.lecture
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

  def lecture_closed
    if @lecture and @lecture.closed
      flash[:alert] = trl("Der Kurs ist zur Bearbeitung geschlossen. Die Aktion konnte nicht durchgeführt werden.")
      redirect_back_or lecture_path(@lecture)
    end
  end

end
