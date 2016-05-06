class Student < Role

  # Associations

  belongs_to :tutorial
  has_many :submissions

  # Scopes

  scope :no_submission, -> (exercise) {
    where(lecture_id: exercise.subject.lecture.id).
      joins("LEFT OUTER JOIN submissions ON roles.id = submissions.student_id AND submissions.exercise_id = #{exercise.id}").
      where("submissions.created_at IS NULL").
      where(":number <= 0 OR roles.group_number = :number", number: exercise.group_number)
  }

  # Scopes for Datatables

  scope :datatables, -> {
    joins("LEFT OUTER JOIN users AS dt_student_users ON dt_student_users.id = roles.user_id").
      joins("LEFT OUTER JOIN tutorials AS dt_tutorials ON dt_tutorials.id = roles.tutorial_id").
      joins("LEFT OUTER JOIN roles AS dt_tutors ON dt_tutorials.id = dt_tutors.tutorial_id AND dt_tutors.type IN ('#{Role::TYPE_TUTOR}')").
      joins("LEFT OUTER JOIN users AS dt_tutor_users ON dt_tutors.user_id = dt_tutor_users.id").
      select("roles.*").
      select("dt_student_users.id AS dt_student_users_id").
      select("dt_student_users.last_name AS dt_student_users_last_name").
      select("dt_student_users.first_name AS dt_student_users_first_name").
      select("dt_student_users.email AS dt_student_users_email").
      select("dt_tutorials.id AS dt_tutorials_id").
      select("dt_tutor_users.last_name AS dt_tutor_users_last_name").
      select("dt_tutor_users.first_name AS dt_tutor_users_first_name").
      select("dt_tutor_users.email AS dt_tutor_users_email")
  }

  scope :missing_subs_datatables, -> (exercise) {
    no_submission(exercise).
      joins("LEFT OUTER JOIN users AS dt_student_users ON dt_student_users.id = roles.user_id").
      joins("LEFT OUTER JOIN tutorials AS dt_tutorials ON roles.tutorial_id = dt_tutorials.id").
      joins("LEFT OUTER JOIN roles AS dt_tutors ON dt_tutorials.id = dt_tutors.tutorial_id AND dt_tutors.type IN ('#{Role::TYPE_TUTOR}')").
      joins("LEFT OUTER JOIN users AS dt_tutor_users ON dt_tutors.user_id = dt_tutor_users.id").
      select("roles.*").
      select("dt_student_users.id AS dt_student_users_id").
      select("dt_student_users.email AS dt_student_users_email").
      select("dt_student_users.first_name AS dt_student_users_first_name").
      select("dt_student_users.last_name AS dt_student_users_last_name").
      select("dt_tutorials.id AS dt_tutorials_id").
      select("dt_tutor_users.id AS dt_tutor_users_id").
      select("dt_tutor_users.email AS dt_tutor_users_email").
      select("dt_tutor_users.first_name AS dt_tutor_users_first_name").
      select("dt_tutor_users.last_name AS dt_tutor_users_last_name")
  }
  
  # Methods

  def submissions_sum
    self.submissions.
      obligation(self.group_number).
      count
  end

  def submissions_max_sum
    self.lecture.exercises.
      obligation(self.group_number).
      count
  end
  
  def submissions_percentage
    return 0 if self.submissions_max_sum == 0
    (self.submissions_sum.to_f / self.submissions_max_sum.to_f)
  end

  def grades_sum
    self.submissions.
      is_statement.obligation(self.group_number).
      joins(:feedback).where(feedbacks: {is_visible: true}).
      sum(:grade)
  end

  def grades_max_sum
    self.lecture.exercises.
      is_statement.obligation(self.group_number).
      sum(:max_points)
  end

  def grades_percentage
    return 0 if self.grades_max_sum == 0
    self.grades_sum.to_f / self.grades_max_sum.to_f
  end

  def passed_sum
    self.submissions.
      obligation(self.group_number).
      joins(:feedback).where(feedbacks: {is_visible: true, passed: true}).
      count
  end

  def passed_max_sum
    self.lecture.exercises.
      obligation(self.group_number).
      count
  end

  def passed_percentage
    return 0 if self.passed_max_sum == 0
    self.passed_sum.to_f / self.passed_max_sum.to_f
  end

end
