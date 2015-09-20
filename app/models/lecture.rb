class Lecture < ActiveRecord::Base

  # Attributes
  #
  # t.string   "name"
  # t.integer  "year"
  # t.string   "term"
  # t.string   "teacher"
  # t.text     "description"
  # t.boolean  "is_visible"
  # t.boolean  "closed"
  # t.integer  "max_group"
  # t.datetime "register_start"
  # t.datetime "register_stop"
  # t.string   "tutor_key"
  # t.string   "teacher_key"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  # Constants

  WINTER_TERM_START = 10
  SUMMER_TERM_START = 4

  # Validations

  validates :year, presence: true
  validates :term, presence: true
  validates :term, inclusion: { in: ["w","s"] }

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:year,:term] }

  validates :max_group, numericality: { only_integer: true, greater_than_or_equal_to: -1 }

  # Associations

  has_many :roles, dependent: :destroy
  has_many :users, :through => :role

  has_many :students
  has_many :tutors
  has_many :teachers

  has_many :tutorials, dependent: :destroy

  has_many :subjects, dependent: :destroy
  has_many :exercises, :through => :subjects

  # Callbacks

  before_save { sanitize_text(:description) }

  def sanitize_text(column)
    # http://www.regular-expressions.info/unicode.html

    if Lecture.exists?(column => self[column])
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
      self[column] = strip_tags(self[column])
    end
  end

  # Delegations

  delegate :valid_students, :invalid_students, :all_students, :to => :students

  # Scopes

  scope :recent, -> {
    where(is_visible: true).
      where(year: 1.year.ago..Date.today)
  }

	# Methods

	def strip_tags(html)
    ActionView::Base.full_sanitizer.sanitize(html)
  end

	# Methods - Exercise naming

  def exercise_name(type)
    column = type.underscore.concat("_name")
    self[column] if Lecture.exists?(column => self[column])
  end

  # Methods - Role control

  def registration_allowed?(time)
    start, stop = 1, 1
    start = time - self.register_start  unless self.register_start.nil?
    stop = self.register_stop - time  unless self.register_stop.nil?
    if start * stop > 0
      return true
    end
    return false
  end

  # Methods - Groups control

  def add_group
    self.max_group += 1
    self.save
  end

  def remove_group
    unless self.max_group < 1
      self.max_group -= 1
      self.save
    end
  end

  def clear_groups
    self.students.each do |student|
      student.group_number = nil
      student.save
    end
  end

  def fill_groups
		students = self.valid_students.where(group_number: nil)
		if students.count >= 3
			grp_number = 0
			students.each do |student|
				student.group_number = 1 + (grp_number%self.max_group)
				student.save
				grp_number += 1
			end
		else
			students.each do |student|
				student.group_number = rand(1..self.max_group)
				student.save
			end
		end
  end

  def refill_groups
		self.clear_groups
		self.fill_groups
  end

  # Methods - Tutorials control

  def non_full_tutorials
    self.tutorials.select { |t| !(t.is_full?) }
  end

  def clear_tutorials
    self.tutorials.each do |tutorial|
      tutorial.students.clear
    end
  end

  def fill_tutorials
    tutorials_array = self.non_full_tutorials.to_a
    tutorials_count = self.non_full_tutorials.count

    self.valid_students.where(tutorial_id: nil).each do |student|
      searching = true # start searching
      if tutorials_count == 0
        searching = false
      end
      while searching
        if tutorials_count == 0
          break
        end
        tut = rand(tutorials_count)
        tutorial = tutorials_array[tut]
        if tutorial.students.count >= tutorial.max_students
          tutorials_array.delete_at(tut)
          tutorials_count = tutorials_count - 1
        else
          tutorial.students << student
          searching = false
        end
      end
    end
  end

  def refill_tutorials
    self.clear_tutorials
    self.fill_tutorials
  end

  def force_fill_tutorials
    needed = self.valid_students.count
    needed_tut = ( needed / self.tutorials.count ) + 1
    self.tutorials.each do |tutorial|
      if tutorial.max_students < needed_tut
        tutorial.update(max_students: needed_tut)
      end
    end
    self.fill_tutorials
  end

  def force_refill_tutorials
    self.clear_tutorials
    self.force_fill_tutorials
  end

  def assign_tutorials
    self.tutorials.each do |tutorial|
      if tutorial.tutor.nil?
        tutor = self.tutors.where(tutorial_id: nil).first
        unless tutor.nil?
          tutor.tutorial = tutorial
          tutor.save
        end
      end
    end
  end

  def deassign_tutorials
    self.tutors.each do |tutor|
      tutor.tutorial = nil
      tutor.save
    end
  end

  def filebasename
    name = self.year.year.to_s + "-"
    name += self.term.upcase + "S" + "-"
    name += self.name.downcase.gsub(" ","_")
  end

end
