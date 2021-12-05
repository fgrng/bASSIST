class SubmissionsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(exercise, view, tutorial = nil)
    @view = view
    @exercise = exercise
    @tutorial = tutorial
  end

  def as_json(options = {})
    {
      echo: params[:sEcho].to_i,
      recordsTotal: recordsTotal,
      recordsFiltered: submissions.total_entries,
      data: data
    }
  end

  # ---
  private

  # ---

  def data
    decorators = SubmissionDecorator.decorate_collection(submissions)
    if @exercise.subject.lecture.show_lsa_score
      decorators.map do |submission|
        [
          ERB::Util.h(submission.dt_student_name),
          ERB::Util.h(submission.dt_tutorial_name),
          ERB::Util.h(submission.dt_group_name),
          ERB::Util.h(submission.dt_passed),
          ERB::Util.h(submission.dt_grade),
          ERB::Util.h(submission.dt_lsa_grade),
          ERB::Util.h(submission.dt_last_change),
          ERB::Util.h(submission.dt_buttons),
          ERB::Util.h(submission.dt_tutor_tr_class)
        ]
      end
    else
      decorators.map do |submission|
        [
          ERB::Util.h(submission.dt_student_name),
          ERB::Util.h(submission.dt_tutorial_name),
          ERB::Util.h(submission.dt_group_name),
          ERB::Util.h(submission.dt_passed),
          ERB::Util.h(submission.dt_grade),
          ERB::Util.h(submission.dt_last_change),
          ERB::Util.h(submission.dt_buttons),
          ERB::Util.h(submission.dt_tutor_tr_class)
        ]
      end
    end
  end

  def recordsTotal
    total = Submission.where(external: false).where("submissions.exercise_id = ?", @exercise.id).datatables
    total = total.where("dt_tutorials_id = ?", @tutorial.id ) unless @tutorial.nil?
    total.to_a.count
  end

  def submissions
    submissions ||= fetch_submissions
  end

  def fetch_submissions
    submissions = Submission.where(external: false).where("submissions.exercise_id = ?", @exercise.id).datatables
    submissions = submissions.where("dt_tutorials_id = ?", @tutorial.id ) unless @tutorial.nil?
    submissions = submissions.order("#{sort_column} #{sort_direction}")
    if params[:search][:value].present?
      submissions = submissions.where("dt_student_users_email like :search or dt_student_users_first_name like :search or dt_student_users_last_name like :search", search: "%#{params[:search][:value]}%")
    end
    submissions = Submission.from("(#{submissions.to_sql})").
                  select("id,text,is_visible,student_id,exercise_id,created_at,updated_at,external,comment")
    submissions = submissions.page(page).per_page(per_page)
    return submissions
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : @exercise.submissions.count
  end

  def sort_column
    if @exercise.subject.lecture.show_lsa_score
      columns = %w[dt_student_users_last_name dt_tutor_users_last_name dt_students_group_number dt_feedbacks_passed dt_feedbacks_grade dt_lsa_scorings_grade submissions.updated_at dt_feedbacks_is_visible]
    else
      columns = %w[dt_student_users_last_name dt_tutor_users_last_name dt_students_group_number dt_feedbacks_passed dt_feedbacks_grade submissions.updated_at dt_feedbacks_is_visible]
    end
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end

end
