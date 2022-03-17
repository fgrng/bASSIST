# coding: utf-8
class RolesController < ApplicationController

  # Filters

  # Variables
  before_action :set_type
  before_action :set_role, except: [:index, :new, :create]
  before_action :set_tutorial, only: [:index]
  before_action :set_lecture

  # Permissions
  before_action :require_login, only: [:new, :create]
  before_action :require_permission_index, only: [:index]
  before_action :require_permission_else, only: [:show, :edit, :update]
  before_action :require_permission_destroy, only: [:destroy]
  before_action :lecture_closed, except: [:index, :index_students, :index_tutors, :index_tutorial, :show]

  # Actions (Resources)

  # Situational Indexing  
  def index
    respond_to do |format|
      format.html {
        if @type == Role::TYPE_TUTOR
          index_tutors
        else
          if @tutorial.nil?
            index_students
          else
            index_tutorial
          end
        end
      }
      format.json {
        if @tutorial.nil?
          render json: ::StudentsDatatable.new(@lecture, view_context)
        else
          render json: ::StudentsDatatable.new(@lecture, view_context, @tutorial)
        end
      }
    end
  end

  def index_students
    render 'roles/index'
  end

  def index_tutors
    @roles = @lecture.send(type_scope).joins(:user).order("users.last_name").decorate
    render 'roles/index'
  end

  def index_tutorial
    render 'roles/index'
  end

  def new
    respond_to do |format|
      format.html { @role = type_class.new }
      format.js { render "roles/new/register_role.js.erb", locals: {type: @type.underscore, lecture: @lecture } }
    end
  end

  def edit
  end

  def update
    if @role.update(role_param)
      flash[:notice] = trl("Die Rolle #{type} wurde erfolgreich aktualisiert.")
      redirect_to 
    else
      render :action => 'edit'
    end
  end

  def create
    @role = @lecture.send(type_scope).build
    @role.user = current_user

    case type
    when Role::TYPE_STUDENT
      if @lecture.registration_allowed?(Time.current)
        if @role.save
          flash[:notice] = trl("Die Rolle #{type} wurde erfolgreich angelegt.")
          redirect_to @lecture
        else
          flash[:alert] = trl("Die Rolle #{type} wurde nicht angelegt.")
          redirect_back_or lectures_path
        end
      else
        flash[:alert] = trl("Die Rolle #{type} wurde nicht angelegt. Registrierung ist nicht geöffnet.")
        redirect_back_or lectures_path
      end
    when Role::TYPE_TUTOR, Role::TYPE_TEACHER
      if params[type.underscore.to_sym][:key] == @lecture.send("#{type.underscore}_key")
        if @role.save
          flash[:notice] = trl("Die Rolle #{type} wurde erfolgreich angelegt.")
          redirect_to @lecture
        else
          flash[:alert] = trl("Die Rolle #{type} wurde nicht angelegt.")
          redirect_back_or lectures_path
        end
      else
        flash[:alert] = trl("Der übertragene Schlüssel war nicht korrekt.")
        redirect_back_or lectures_path
      end
    end
  end

  def destroy
    @role.destroy
    flash[:notice] = trl("Die Rolle #{type} wurde erfolgreich entfernt.")
    redirect_to lecture_students_path(@lecture)
  end

  # Actions (Validate Students)

  def toggle_validation
    if @role.validated
      # Quickly toggle (skip validations with update_attribute).
      @role.update_attribute(:validated, false)
    else
      # Quickly toggle (skip validations with update_attribute).
      @role.update_attribute(:validated, true)
      UserMailer.data_verified(@role).deliver
    end
    flash[:notice] = trl("Validationsstatus geändert.")
    redirect_to lecture_students_path(@lecture)
  end

  # Actions (Tutorial Assignment)

  def assign
    tutorial = Tutorial.find(params[:tutorial_id])
    unless tutorial.lecture != @role.lecture
      case type
      when Role::TYPE_STUDENT
        tutorial.students << @role
        flash[:notice] = trl("Student wurde erfolgreich zugeordnet.")
        redirect_back_or lecture_tutorials_path(@lecture)
      when Role::TYPE_TUTOR
        tutorial.tutor = @role
        tutorial.save
        flash[:notice] = trl("Tutor wurde erfolgreich zugeordnet.")
        redirect_back_or lecture_tutorials_path(@lecture)
      end
    else
      flash[:alert] = trl("Lecture of Tutorial and Role doesn't match.")
      redirect_to @lecture.tutorials
    end
  end

  # ---

  private

	# ---

  # Single Table Inheritance

  def type 
    params[:type] || "Role" 
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

  def set_role
    @role = type_class.find(params[:id])
  end

  def set_lecture
    if params[:lecture_id]
      @lecture = Lecture.find(params[:lecture_id]).decorate
    elsif !(@tutorial.nil?)
      @lecture = @tutorial.lecture
    else
      @lecture = @role.lecture
    end
  end

  def set_tutorial
    if params[:tutorial_id]
      @tutorial = Tutorial.find(params[:tutorial_id])
    end
  end

  # Strong Parameters

  def role_params
    case type
    when Role::TYPE_STUDENT
      params.require(type.underscore.to_sym).permit()
    when Role::TYPE_TUTOR
      params.require(type.underscore.to_sym).permit()
    when Role::TYPE_TEACHER
      params.require(type.underscore.to_sym).permit()
    end
  end

  # Permissions

  def require_login
    unless signed_in?
      flash[:alert] = trl("Sie müssen angemeldet sein, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def require_permission_index
    unless require_login
      unless current_user.is_teacher_or_tutor?(@lecture)
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def require_permission_destroy
    unless require_login
      unless current_user.is_teacher?(@lecture)
        flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
        redirect_back_or root_path
      end
    end
  end

  def require_permission_else
    unless require_login
      case type
      when Role::TYPE_STUDENT
        unless current_user == @role.user or
							current_user.is_teacher_or_tutor?(@lecture)
          flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
          redirect_back_or root_path
        end
      when Role::TYPE_TUTOR
        unless current_user == @role.user or
							current_user.is_teacher?(@lecture)
          flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
          redirect_back_or root_path
        end
      when Role::TYPE_TEACHER
        unless current_user == @role.user
          flash[:alert] = trl("Sie haben nicht die nötige Berechtigung, um diese Aktion auszuführen.")
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

