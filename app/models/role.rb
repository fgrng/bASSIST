class Role < ApplicationRecord

  # Attributes
  #
  # t.string   "type"
  # t.boolean  "validated"
  # t.integer  "user_id"
  # t.integer  "lecture_id"
  # t.integer  "tutorial_id"
  # t.integer  "group_number"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  # Constants

  TYPES = [TYPE_STUDENT = 'Student', TYPE_TUTOR = 'Tutor', TYPE_TEACHER = 'Teacher']

  # Associations

  belongs_to :lecture
  belongs_to :user

  # Delegations

  delegate :email, :to => :user
  delegate :first_name, :to => :user
  delegate :last_name, :to => :user

  # Validations

  validates :type, :presence => true
  validates :type, inclusion: {in: TYPES}
  validates :lecture_id, :presence => true
  validates_presence_of :lecture
  validates :user_id, :presence => true
  validates_presence_of :user

  validates :lecture_id, uniqueness: { scope: :user,
    message: "Nur eine Rolle pro Kurs" }

  # Scopes

	scope :recent, -> {
		joins(:lecture).
			where(lectures: { is_visible: true } ).
      where(lectures: {year: 1.year.ago..Date.today} )
	}

	scope :students, -> { where(type: TYPE_STUDENT) }
  scope :valid_students, -> { where(type: TYPE_STUDENT, validated: true) }
  scope :invalid_students, -> { where(type: TYPE_STUDENT, validated: false) }
  scope :all_students, -> { where(type: TYPE_STUDENT, validated: false) }

  scope :tutors, -> { where(type: TYPE_TUTOR) }
	
  scope :teachers, -> { where(type: TYPE_TEACHER) }

end
