class User < ApplicationRecord

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

  before_validation { strip_email }
  before_validation { strip_username }
  after_create { send_email_validation }

  # Validations

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: VALID_EMAIL_HD_REGEX }

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :validated, inclusion: { in: [true, false] }

  # Associations

  has_many :roles, dependent: :destroy
  has_many :lectures, :through => :roles
  belongs_to :active_lecture, :class_name => "Lecture"

  # Delegations

  delegate :students, :invalid_students, :valid_students, :all_students, :tutors, :teachers, :to => :roles

  # Scopes

  scope :verified, -> { where(validated: true) }

  # Class Methods

  def self.signin_find(login)
    unless login.nil? or login.blank?
      where("LOWER(email) = :login", login: login.downcase).last
    else
      return nil
    end
  end

  # Modified Setter/Getter

  def remember_token=(remember_token)
    write_attribute(:remember_token, Digest::SHA1.hexdigest(remember_token.to_s))
  end

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

  # Methods: Mail Validation & Password reset

  def verify
    return (self.update_attribute(:email_validation_token, nil) and
            self.update_attribute(:validated, true))
  end

  def send_email_validation
    if self.dummy
      self.verify
    else
      generate_token(:email_validation_token)
      self.email_validation_sent_at = Time.current
      if self.save
        UserMailer.email_validation(self).deliver_later
      end
    end
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.current
    if self.save
      UserMailer.password_reset(self).deliver_later
    end
  end

  def is_dummy?
    self.dummy
  end

	# ---

	private

	# ---

  def strip_email
    unless self.email.nil?
      self.email = self.email.to_s
      self.email.downcase!
      self.email = self.email.strip
      self.email.gsub!(/[\p{Z}\t\f]/,"")
    end
  end

  def strip_username
    unless self.first_name.nil?
      self.first_name = self.first_name.to_s
      self.first_name = self.first_name.strip
      self.first_name.gsub!(/[\p{Z}\t\f]/,"")
    end
    unless self.last_name.nil?
      self.last_name = self.last_name.to_s
      self.last_name = self.last_name.strip
      self.last_name.gsub!(/[\p{Z}\t\f]/,"")
    end
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
      return self[column]
    end while User.exists?(column => self[column])
  end

end
