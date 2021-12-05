class SubmissionDecorator < ApplicationDecorator

  # Delegation

  delegate_all

  # Associations

  decorates_association :student
  decorates_association :feedback
  decorates_association :exercise

  # Methods

  def htmlize_text
    output = "".html_safe
    paragraphs = object.text.split(/\R\R/)
    paragraphs.each do |p|
      output += h.content_tag :p,  p
    end
    return output
  end

  def student_full_name
    handle_external do
      object.student.decorate.full_name
    end
  end

  def student_first_name
    handle_external do
      object.student.decorate.first_name
    end
  end

  def student_last_name
    handle_external do
      object.student.decorate.last_name
    end
  end

  def student_list_name
    handle_external do
      object.student.decorate.list_name
    end
  end

  def student_email
    handle_external do
      object.student.decorate.email
    end
  end

  def student_email_raw
    handle_external do
      object.student.decorate.email_raw
    end
  end

  def student_email_full_name
    handle_external do
      object.student.decorate.email_full_name
    end
  end

  def student_email_list_name
    handle_external do
      object.student.decorate.email_list_name
    end
  end

  def lsa_position
    scoring = LsaSorting.where(submission: object).last
    return scoring.position unless scoring.nil?
    return nil
  end

  def lsa_grade
    scoring = LsaScoring.where(submission: object).last
    return scoring.grade unless scoring.nil?
    return nil
  end

  # DataTables

  def dt_student_name
    handle_external do
      h.render(
        :partial => 'roles/index/students_info_button',
        :formats => :html,
        :locals => {:name => student_list_name,
                    :email => student_email_raw })
    end
  end

  def dt_tutorial_name
    handle_external do
      unless object.student.nil?
        unless object.student.tutorial.nil?
          object.student.tutorial.decorate.name
        else
          return "kein Tutorium"
        end
      else
        ""
      end
    end
  end

  def dt_group_name
    handle_external do
      unless object.student.nil?
        object.student.decorate.group_to_exercise(object.exercise) + " (" + object.student.decorate.group_name + ")"
      else
        return "kein*e Student*in"
      end
    end
  end

  def dt_passed
    handle_no_feedback do
      return "Ja" if object.feedback.passed
      return "Nein"
    end
  end

  def dt_grade
    handle_no_feedback do
      if Exercise::TYPE_STATEMENTS.include?(object.exercise.type)
        return "#{object.feedback.grade} / #{object.exercise.max_points}"
      else
        return ""
      end
    end
  end

  def dt_lsa_grade
    if Exercise::TYPE_STATEMENTS.include?(object.exercise.type)
      scoring = LsaScoring.where(submission: object).last
      unless scoring.nil?
        return "#{scoring.grade} / #{object.exercise.max_points}"
      end
    end
    return ""
  end

  def dt_last_change
    self.date_to_string_short(object.updated_at)
  end

  def dt_comment
    self.comment
  end

  def  dt_buttons
    unless object.feedback.nil?
      dt_btn_feedback
    else
      dt_btn_no_feedback
    end
  end

  def dt_btn_no_feedback
    h.render(
      :partial => 'submissions/index/buttons_no_feedback',
      :formats => :html,
      :locals => {:submission => object }
    )
  end

  def dt_btn_feedback
    h.render(
      :partial => 'submissions/index/buttons_feedback',
      :formats => :html,
      :locals => {:submission => object, :feedback => object.feedback }
    )
  end

  def dt_tutor_tr_class
    return "none" if object.external
    unless object.feedback.nil?
      if object.feedback.is_visible
        return "success" if object.feedback.passed
        return "danger"
      else
        return "info" if object.feedback.passed
        return "warning"
      end
    else
      "none"
    end
    return "success" if object.external
  end

  private

  def handle_no_feedback
    unless object.feedback.nil?
      yield
    else
      return "kein Feedback"
    end
  end

  def handle_external
    if object.external
      return "Zusatzabgabe"
    elsif object.student.nil?
      return "kein Student"
    else
      yield
    end
  end

end
