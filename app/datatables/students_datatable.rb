class StudentsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(lecture, view, tutorial = nil)
    @view = view
    @lecture = lecture
    @tutorial = tutorial unless tutorial.nil?
  end

  def as_json(options = {})
    {
      echo: params[:sEcho].to_i,
      recordsTotal: total_records,
      recordsFiltered: students.total_entries,
      data: data
    }
  end

	# ---

	private

	# ---

  def data
    return data_tutorial unless @tutorial.nil?
    decorators = StudentDecorator.decorate_collection(students)
    decorators.map do |student|
      [
        ERB::Util.h(@view.render(
                     :partial => 'roles/index/students_info_button',
                     :formats => :html,
                     :locals => {:name => student.decorate.list_name,
                                 :email => student.decorate.email_raw })),
        ERB::Util.h(student.group_name),
        ERB::Util.h(student.tutorial_name),
        ERB::Util.h(@view.render(
                     :partial => 'roles/index/students_validate_button',
                     :formats => :html,
                     :locals => {:role => student} ))
      ]
    end
  end

  def data_tutorial
    decorators = StudentDecorator.decorate_collection(students)
    # TODO
    decorators.map do |student|
      [
        ERB::Util.h(student.dt_list_name),
        ERB::Util.h(student.dt_group_name),
        ERB::Util.h(student.dt_submissions),
        ERB::Util.h(student.dt_grades),
        ERB::Util.h(student.dt_passed),
      ]
    end
  end

  def total_records
    return total_records_tutorial unless @tutorial.nil?  
    total = Student.where("roles.lecture_id = ?", @lecture.id).datatables
    total.to_a.count
  end

  def total_records_tutorial
    total = Student.
            where("roles.lecture_id = ?", @lecture.id).
            where("roles.tutorial_id = ?", @tutorial.id).
            datatables
    total = Role.from("(#{total.to_sql})").
            select("id,lecture_id,type,user_id,type,tutorial_id,validated,created_at,updated_at,group_number")
    total.count
  end
  
  def students
    students ||= fetch_students
  end
  
  def fetch_students
    students = Student.where("roles.lecture_id = ?", @lecture.id).datatables
    students = students.where("dt_tutorials_id = ?", @tutorial.id) unless @tutorial.nil?
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
    params[:length].to_i > 0 ? params[:length].to_i : @lecture.students.count
  end

  def sort_column
    return sort_column_tutorial unless @tutorial.nil?  
    columns = %w[dt_student_users_last_name roles.group_number dt_tutor_users_last_name roles.validated]
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_column_tutorial
    columns = %w[dt_student_users_last_name roles.group_number]
    columns[params[:order]["0"][:column].to_i]    
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end

end
