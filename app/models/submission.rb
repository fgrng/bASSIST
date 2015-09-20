# coding: utf-8
class Submission < ActiveRecord::Base
  
  # Attributes
  #
  # t.text     "text"
  # t.integer  "student_id"
  # t.integer  "exercise_id"
  # t.boolean  "is_visible"
  # t.boolean  "external"
  # t.string   "comment"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  # Associations

  belongs_to :exercise
  belongs_to :student

  has_one :feedback, dependent: :destroy

  # Validations

  validates :exercise_id, :presence => true
  validates_presence_of :exercise
  
  validate :validate_submission_per_exercise, :on => :create

  def validate_submission_per_exercise
    unless self.student.nil?
      if Submission.from_student(self.student).from_exercise(self.exercise).count > 0
        errors.add(:submission, "already present. You can't create another one.")
      end
    end
  end

  # Callbacks

  before_save { sanitize_text(:text) }

  def sanitize_text(column)
    # http://www.regular-expressions.info/unicode.html

    if Submission.exists?(column => self[column])
      # Allow only characters in Common, Latin, Greek (for math).
      self[column] = self[column].gsub(/[^\p{Common}\p{Latin}\p{Greek}]/, "") 
      # Replace linebreaks with '\n'
      self[column] = self[column].gsub(/\R/,"\n")
      # Remove single linebreaks
      self[column] = self[column].gsub(/(\S.*?)\R(.*?\S)/,'\1 \2')
      # Replace multiple whitespaces with one whitespace
      self[column] = self[column].gsub(/[\p{Z}\t\f]{2,}/," ")
      # Remove whitespaces at beginning/end of line
      self[column] = self[column].gsub(/^\p{Z}|\p{Z}$/, "")
      # Replace multiple linebreaks with one/two
      self[column] = self[column].gsub(/\R{3,}/,"\n\n")
      # Remove HTML Markup
      self[column] = self.strip_tags(self[column])
    end
  end

  # Scopes

  scope :visible, -> {
    joins(:exercise => :subject).
      where("(submissions.is_visible = ? OR subjects.due_date < ?)", true, Time.current)
  }

  scope :from_user, -> (user) { 
    joins(:student).where( :roles => { user_id: user.id } )
  }
  scope :from_student, -> (student) {
    where( student_id: student.id )
  }
  scope :from_group, -> (group) {
    joins(:exercise).where( :exercises => { group_number: group } )
  }
  scope :obligation, -> (group) {
    joins(:exercise).where( :exercises => { group_number: [-1,group] } )
  }
  scope :voluntary, -> (group) {
    joins(:exercise).where.not( :exercises => { group_number: [-1,group] } )
  }
  scope :from_tutorial, -> (tutorial) {
    joins(:student).where( :roles => { tutorial_id: tutorial.id } )
  }
  scope :from_exercise, -> (exercise) {
    where( exercise_id: exercise.id )
  }
  scope :from_subject, -> (subject) {
    joins(:exercise => :subject).where( :subjects => { :id => subject.id } )
  }
  scope :from_lecture, -> (lecture) {
    joins(:exercise => { :subject => :lecture } ).where( :lectures => { :id => lecture.id } )
  }
  scope :is_statement, -> {
    joins(:exercise).where( :exercises => { type: Exercise::TYPE_STATEMENTS} )
  }
  scope :is_reflection, -> {
    joins(:exercise).where( :exercises => { type: Exercise::TYPE_REFLECTIONS} )
  }
  scope :with_feedback, -> {
    select { |s| s.feedback != nil }
  }

  scope :datatables, -> {
    visible.
      joins("LEFT OUTER JOIN feedbacks AS dt_feedbacks ON dt_feedbacks.submission_id = submissions.id").
      joins("LEFT OUTER JOIN roles AS dt_students ON dt_students.id = submissions.student_id").
      joins("LEFT OUTER JOIN users AS dt_student_users ON dt_students.user_id = dt_student_users.id").
      joins("LEFT OUTER JOIN tutorials AS dt_tutorials ON dt_tutorials.id = dt_students.tutorial_id").
      joins("LEFT OUTER JOIN roles AS dt_tutors ON ( dt_tutors.tutorial_id = dt_tutorials.id AND dt_tutors.type IN ('#{Role::TYPE_TUTOR}') )").
      joins("LEFT OUTER JOIN users AS dt_tutor_users ON dt_tutors.user_id = dt_tutor_users.id").
      joins("LEFT OUTER JOIN exercises AS dt_exercises ON dt_exercises.id = submissions.exercise_id").
      select("submissions.*").
      select("dt_students.group_number AS dt_students_group_number").
      select("dt_student_users.id AS dt_student_users_id").
      select("dt_student_users.email AS dt_student_users_email").
      select("dt_student_users.first_name AS dt_student_users_first_name").
      select("dt_student_users.last_name AS dt_student_users_last_name").
      select("dt_tutorials.id AS dt_tutorials_id").
      select("dt_tutor_users.id AS dt_tutor_users_id").
      select("dt_tutor_users.email AS dt_tutor_users_email").
      select("dt_tutor_users.first_name AS dt_tutor_users_first_name").
      select("dt_tutor_users.last_name AS dt_tutor_users_last_name").
      select("dt_exercises.id AS dt_exercises_id").
      select("dt_exercises.group_number AS dt_exercises_group_number").
      select("dt_feedbacks.id AS dt_feedbacks_id").
      select("dt_feedbacks.is_visible AS dt_feedbacks_is_visible").
      select("dt_feedbacks.grade AS dt_feedbacks_grade").
      select("dt_feedbacks.passed AS dt_feedbacks_passed")
  }

  # Delegations

  delegate :type, :to => :exercise

  # Methods

  def strip_tags(html)
    ActionView::Base.full_sanitizer.sanitize(html)
  end

  def text_xml_valid
    # http://www.w3.org/TR/REC-xml/#charsets
    # https://stackoverflow.com/questions/397250/unicode-regex-invalid-xml-characters
    self.text.gsub(/[^\u0009\u000a\u000d\u0020-\uD7FF\uE000-\uFFFD]/,"")
  end

  def submission_allowed?
    if self.exercise.time_left > 0 and !(self.is_visible)
      return true
    else
      return false
    end
  end

  def visible?
    return !(submission_allowed?)
  end

  def htmlize_text
    output = ""
    paragraphs = self.text.split(/\R\R/)
    paragraphs.each do |p|
      output += "<p>" + p + "</p>"
    end
    return output
  end

  def passed?
    unless self.feedback.nil?
      return self.feedback.passed
    else
      return false
    end
  end

  def grade
    unless self.feedback.nil?
      return self.feedback.grade
    else
      return nil
    end
  end

  def graded?
    !(self.grade.nil?)
  end

end
