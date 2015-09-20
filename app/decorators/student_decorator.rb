# coding: utf-8
class StudentDecorator < RoleDecorator

  # Delegations

  delegate_all

  # Associations

  decorates_association :tutorial

  # Methods

  def group_name
    return ExerciseDecorator::GRP_NONE if object.group_number.nil? or object.group_number <= 0
    return ('A'..'ZZ').to_a[object.group_number-1]
  end

  def group_to_exercise(exercise)
    if exercise.group_number == -1 or exercise.group_number == object.group_number
      return ExerciseDecorator::GRP_EQUAL
    end
    return ExerciseDecorator::GRP_DIFF
  end

  def tutorial_name
    return object.tutorial.decorate.name unless object.tutorial.nil?
    return "Kein Tutorium"
  end

  # Datatables

  def dt_student_group(exercise)
    group_to_exercise(exercise)
  end

  def dt_group_name
    group_name
  end

  def dt_missing_subs_buttons(exercise)
    h.render(
      :partial => 'submissions/index/buttons_no_submission',
      :formats => :html,
      :locals => {:student => object, :exercise => exercise }
    )
  end

  def dt_oblig_tr_class(exercise)
    if exercise.group_number == -1 or exercise.group_number == object.group_number
      return "info"
    else
      return "none"
    end      
  end

  # Student Index for Tutors

  def dt_submissions
    output = object.submissions_sum.to_s
    output += " / "
    output += object.submissions_max_sum.to_s
    output += " ("
    output += (object.submissions_percentage * 100).round(2).to_s 
    output += "%)"
  end

  def dt_passed
    output = object.passed_sum.to_s
    output += " / "
    output += object.passed_max_sum.to_s
    output += " ("
    output += (object.passed_percentage * 100).round(2).to_s
    output += "%)"
  end

  def dt_grades
    output = object.grades_sum.to_s
    output += " / "
    output += object.grades_max_sum.to_s
    output += " ("
    output += (object.grades_percentage * 100).round(2).to_s
    output += "%)"
  end

  # Subject Index for Student

  def dt_submission_edit_tr_class(exercise)
    subject = exercise.subject
    submission = object.submissions.from_exercise(exercise).last

    # Feedback vorhanden?
    unless submission.nil? or submission.feedback.nil?
      return self.dt_feedback_status_tr_class(submission)
    end

    # Bestimme Bearbeitungsstatus
    if self.group_to_exercise(exercise) == ExerciseDecorator::GRP_EQUAL
      # Pflichtaufgabe, Abgabe möglich
      return "info" if subject.submission_possible(submission)
      # Pflichtaufgabe, Abgabe nicht möglich
      return "warning"
    else
      # Freiwillige Aufgabe
      return "none"
    end
  end

  def dt_feedback_status_tr_class(submission)
    feedback = submission.feedback
    if feedback.nil?
      return "warning"
    else
      return "success" if feedback.passed
      return "danger"
    end
  end

  def dt_submission_buttons(exercise)
    submission = object.submissions.from_exercise(exercise).last
    if submission.nil?
      return dt_submission_buttons_new(exercise)
    else
      return dt_submission_buttons_edit(submission)
    end
  end

  def dt_submission_buttons_new(exercise)
    subject = exercise.subject
    if subject.submission_allowed?
      h.render(
        :partial => 'submissions/index/buttons_new',
        :formats => :html,
        :locals => {:exercise => exercise }
      )
    else
      h.render(
        :partial => 'submissions/index/buttons_new_disabled',
        :formats => :html,
      )
    end
  end

  def dt_submission_buttons_edit(submission)
    subject = submission.exercise.subject
    h.content_tag :div, class: "btn-group" do
      output = h.render(
        :partial => 'submissions/index/buttons_show',
        :formats => :html,
        :locals => {:submission => submission }
      )
      if subject.submission_possible(submission)
        output += h.render(
          :partial => 'submissions/index/buttons_edit',
          :formats => :html,
          :locals => {:submission => submission }
        )
      else
        output += h.render(
          :partial => 'submissions/index/buttons_edit_disabled',
          :formats => :html,
        )
      end
    end
  end

end
