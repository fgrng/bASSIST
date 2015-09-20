class User < ActiveRecord::Base

  # Attributes
  #
  # t.string   "email"
  # t.string   "first_name"
  # t.string   "last_name"
  # t.string   "password_digest"
  # t.boolean  "validated"
  # t.boolean  "is_admin"
  # t.boolean  "is_assistant"
  # t.string   "remember_token"
  # t.integer  "active_lecture_id"
  # t.string   "password_reset_token"
  # t.datetime "password_reset_sent_at"
  # t.string   "email_validation_token"
  # t.datetime "email_validation_sent_at"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  has_secure_password

  # Constants

  VALID_EMAIL_REGEX = Figaro.env.valid_email_regex
  VALID_EMAIL_HD_REGEX = /\A[\w+\-._]+@[a-z\d\-.]+\.uni\-heidelberg\.de/i

  # Callbacks

  before_create { generate_token(:remember_token) }
  before_validation { email.downcase! }
  before_save { strip_whitespaces }
  # after_create { send_email_validation }

  # Validations

  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_HD_REGEX }
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Associations

  has_many :roles, dependent: :destroy
  has_many :lectures, :through => :roles
  belongs_to :active_lecture, :class_name => "Lecture"

  # Delegations

  delegate :students, :invalid_students, :valid_students, :all_students, :tutors, :teachers, :to => :roles

  # Scopes

  scope :verified, -> { where(validated: true) }

  # Methods

  def strip_whitespaces
    self.email = self.email.strip
    self.first_name = self.first_name.strip
    self.last_name = self.last_name.strip
  end

  # Methods: Roles

  def has_role?(lecture)
    lec = self.roles.where( lecture_id: lecture.id ).first
    unless lec.nil?
      return true
    else
      return false
    end
  end

  def get_role(lecture)
    self.roles.where( lecture_id: lecture.id ).first
  end

  def is_student?(lecture)
    lec = self.valid_students.where(lecture_id: lecture.id ).first
    unless lec.nil?
      return true
    else
      return false
    end
  end

  def is_invalid_student?(lecture)
    lec = self.invalid_students.where(lecture_id: lecture.id ).first
    unless lec.nil?
      return true
    else
      return false
    end
  end

  def get_student(lecture)
    self.students.where( lecture_id: lecture.id ).first
  end

  def is_tutor?(lecture)
    lec = self.tutors.where( lecture_id: lecture.id ).first
    unless lec.nil?
      return true
    else
      return false
    end
  end

  def get_tutor(lecture)
    self.tutors.where( lecture_id: lecture.id ).first
  end

  def is_teacher?(lecture)
    lec = self.teachers.where( lecture_id: lecture.id ).first
    unless lec.nil?
      return true
    else
      return false
    end
  end

  def get_teacher(lecture)
    self.teachers.where( lecture_id: lecture.id ).first
  end

  def is_teacher_or_tutor?(lecture)
    lec1 = self.teachers.where( lecture_id: lecture.id ).first
    lec2 = self.tutors.where( lecture_id: lecture.id ).first
    if lec1 || lec2
      return true
    else
      return false
    end
  end

  def is_tutor_or_teacher?(lecture)
    return self.is_teacher_or_tutor?(lecture)
  end
  
  def has_tutor?
    return true if self.tutors.count > 0
    return false
  end

  def has_teacher?
    return true if self.teachers.count > 0
    return false
  end

  # Methods: Sessions (Class)

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  # Methods: Mail Validation & Password reset

  def verify
    return (self.update_attribute(:email_validation_token, nil) and
            self.update_attribute(:validated, true))
  end

  def send_email_validation
    generate_token(:email_validation_token)
    self.email_validation_sent_at = Time.current
    save!
    UserMailer.email_validation(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.current
    save!
    UserMailer.password_reset(self).deliver
  end

	# ---

	private

	# ---

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

end
