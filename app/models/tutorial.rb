class Tutorial < ApplicationRecord

  # Attributes
  #
  # t.integer  "lecture_id"
  # t.integer  "max_students"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  # Associations
  
  belongs_to :lecture
  has_one :tutor
  has_many :students

  has_many :submissions, :through => :students

  # Validation

  validates :lecture, presence: true
  validates_presence_of :lecture

  # Delegations

  delegate :valid_students, :invalid_students, :all_students, :to => :students

  # Methods

  def is_full?
    return true if self.valid_students.count >= self.max_students
    return false
  end

end
