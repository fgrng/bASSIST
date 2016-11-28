class Feedback < ApplicationRecord

  # Attributes
  # 
  # t.text     "text"
  # t.boolean  "passed"
  # t.float    "grade"
  # t.boolean  "is_visible"
  # t.integer  "submission_id"
  # t.datetime "created_at"
  # t.datetime "updated_at"

  # Associations

  belongs_to :submission

  # Validations

  validates :submission_id, :presence => true
  validates_presence_of :submission

  # Callbacks

  before_save { sanitize_text(:text) }
  
  def sanitize_text(column)
    # http://www.regular-expressions.info/unicode.html

    if Feedback.exists?(column => self[column])
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

  scope :from_exercise, -> (exercise) {
    joins(:submission).where( :submission => { exercise: exercise } )
  }

  # Methods

  def strip_tags(html)
    ActionView::Base.full_sanitizer.sanitize(html)
  end

  def mail_notification
    UserMailer.feedback(self).deliver
  end

  def text_xml_valid
    # http://www.w3.org/TR/REC-xml/#charsets
    # https://stackoverflow.com/questions/397250/unicode-regex-invalid-xml-characters
    self.text.gsub(/[^\u0009\u000a\u000d\u0020-\uD7FF\uE000-\uFFFD]/,"")
  end

end
