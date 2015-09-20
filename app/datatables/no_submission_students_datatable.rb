class NoSubmissionStudentsDatatable
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
      recordsFiltered: students.total_entries,
      data: data
    }
  end

	# ---

	private

	# ---

  def data
    decorators = StudentDecorator.decorate_collection(students)
    decorators.map do |student|
      [
        ERB::Util.h(student.dt_list_name),
        ERB::Util.h(student.dt_tutorial_name),
        ERB::Util.h(student.dt_student_group(@exercise)),
        ERB::Util.h(student.dt_missing_subs_buttons(@exercise)),
        ERB::Util.h(student.dt_oblig_tr_class(@exercise))
      ]
    end
  end

  def recordsTotal
    total = Student.missing_subs_datatables(@exercise)
    total = total.where("dt_tutorials_id =?", @tutorial.id) unless @tutorial.nil?
    total.to_a.count
  end

  def students
    students ||= fetch_students
  end
  
  def fetch_students
    students = Student.missing_subs_datatables(@exercise)
    students = students.where("dt_tutorials_id =?", @tutorial.id) unless @tutorial.nil?
    students = students.order("#{sort_column} #{sort_direction}")
    if params[:search][:value].present?
      students = students.where("dt_student_users_email like :search or dt_student_users_first_name like :search or dt_student_users_last_name like :search", search: "%#{params[:search][:value]}%")
    end
    students = Role.from("(#{students.to_sql})").
               select("id,lecture_id,type,user_id,type,tutorial_id,validated,created_at,updated_at,group_number")
    students = students.page(page).per_page(per_page)
    return students
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 25
  end

  def sort_column
    columns = %w[dt_student_users_last_name dt_tutor_users_last_name students.group_number]
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end

end

