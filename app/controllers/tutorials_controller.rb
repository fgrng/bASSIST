# coding: utf-8
class TutorialsController < ApplicationController

  # Filters

  # Set Variables
  before_action :set_tutorial, except: [:index, :new, :create]
  before_action :set_lecture

  # Permissions
  before_action :require_permission, except: [:show]
  before_action :require_permission_show, only: [:show]  
  before_action :lecture_closed, except: [:index, :show]
  
  # Actions (Resources)

  def index
    @tutorials = @lecture.tutorials.decorate
  end

  def show
  end

  def new
    @tutorial = Tutorial.new
  end

  def create
    @tutorial = @lecture.tutorials.build(tutorial_params)
    if @tutorial.save
      flash[:notice] = trl("Tutorial was successfully created.")
      redirect_to lecture_tutorials_path(@lecture)
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tutorial.update(tutorial_params)
      flash[:notice] = trl("Tutorial was successfully updated.")
      redirect_to lecture_tutorials_path(@lecture)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @tutorial.destroy
    flash[:notice] = trl("Tutorial was successfully deleted.")
    redirect_to lecture_tutorials_path(@lecture)
  end

  # ---

  private

	# ---

  # Variables

  def set_tutorial
    @tutorial = Tutorial.find(params[:id]).decorate
  end

  def set_lecture
    if params[:lecture_id]
      @lecture = Lecture.find(params[:lecture_id]).decorate
    else
      @lecture = @tutorial.lecture
    end
  end

  # Strong Parameters

  def tutorial_params
    params.require(:tutorial).permit(:tutor_id,
                                     :max_students)
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

  def require_permission_show
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    else
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
