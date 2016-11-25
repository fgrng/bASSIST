class Subject < ActiveRecord::Base

  # Attributes
  #
  # t.string   "name"
  # t.datetime "due_date"
  # t.datetime "start_date"
  # t.integer  "lecture_id"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  # Associations

  belongs_to :lecture

  has_many :exercises, dependent: :destroy, inverse_of: :subject

  has_many :statements
	has_many :a_statements
	has_many :b_statements
	has_many :c_statements
	
  # 'transactions' is a new reserved keyword in rails 4.1
  has_many :contemplations, class_name: "Transaction", foreign_key: 'transaction_id'

	has_many :a_reflections
	has_many :b_reflections
	has_many :c_reflections
	
  has_many :comments

  # Validations

  validates :name, :presence => true
  validates :lecture_id, :presence => true
  validates_presence_of :lecture
  validates :due_date, :presence => true

  # Scopes

  scope :visible, -> {
    where("subjects.start_date < ?", Time.current() )
  }

  # Methods

  def visible?
    if self.start_date.nil?
      return true
    else
      return ( self.start_date - Time.current() ) < 0
    end
  end

  def time_left
    self.due_date - Time.current()
  end

  def submission_allowed?
    if self.time_left > 0 and self.visible?
      return true
    else
      return false
    end
  end

  def submission_possible(submission)
    unless self.submission_allowed?
      return false
    else
      # Time is running
      if submission.nil?
        return true
      elsif submission.is_visible
        return false
      else
        return true
      end
    end
  end

end
