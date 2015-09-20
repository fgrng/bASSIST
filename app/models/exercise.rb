class Exercise < ActiveRecord::Base

  # Attributes
  #
  # t.integer  "subject_id"
  # t.string   "type"
  # t.text     "text"
  # t.text     "ideal_solution"
  # t.float    "min_points"
  # t.float    "max_points"
  # t.datetime "created_at"
  # t.datetime "updated_at"
  # t.integer  "group_number"
  
  # Constants
  
  TYPES = [
    TYPE_STATEMENTS = [
      TYPE_STATEMENT_BASE = 'Statement',
      TYPE_STATEMENT_A = 'AStatement',
      TYPE_STATEMENT_B = 'BStatement',
      TYPE_STATEMENT_C = 'CStatement',
    ],
    TYPE_REFLECTIONS = [
      TYPE_REFLECTION_BASE = 'Reflection',
      TYPE_REFLECTION_A = 'AReflection',
      TYPE_REFLECTION_B = 'BReflection',
      TYPE_REFLECTION_C = 'CReflection',
    ]

  ]

  # Associations

  belongs_to :subject, inverse_of: :exercises

  has_many :submissions, dependent: :destroy
  has_and_belongs_to_many :lsa_runs

  # Validations

  validates :type, :presence => true

  # Callbacks

  before_save { sanitize_text(:text) }
  before_save { sanitize_text(:ideal_solution) }
  
  def sanitize_text(column)
    # http://www.regular-expressions.info/unicode.html

    if Exercise.exists?(column => self[column])
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

  # Scopes

  scope :is_statement, -> { where(type: TYPE_STATEMENTS) }
  scope :is_reflection, -> { where(type: TYPE_REFLECTIONS) }

  scope :obligation, -> (group) {
    where(group_number: [-1,group])
  }
  scope :voluntary, -> (group) {
    where.not(group_number: [-1,group])
  }
  scope :no_submission, -> (student) {
    obligation(student.group_number).select { |e| e.submissions.find_by_student_id(student.id).nil? }
  }
  
  # Delegations

  delegate :time_left, :to => :subject
  delegate :submission_allowed?, :to => :subject

  # Methods

  def strip_tags(html)
    ActionView::Base.full_sanitizer.sanitize(html)
  end

  def text_xml_valid
    # http://www.w3.org/TR/REC-xml/#charsets
    # https://stackoverflow.com/questions/397250/unicode-regex-invalid-xml-characters
    self.text.gsub(/[^\u0009\u000a\u000d\u0020-\uD7FF\uE000-\uFFFD]/,"")
  end

	# stupid workaround for collection_check_boxes
	def checkbox_name
		self.decorate.name
	end

end
