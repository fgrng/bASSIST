class LsaRun < ActiveRecord::Base

  # Attributes
  #
  # t.string   "type"
  # t.text     "ideal_solution"
  # t.text     "first_scored_text"
  # t.text     "second_scored_text"
  # t.float    "first_text_score"
  # t.float    "second_text_score"
  # t.string   "error_message"
  # t.datetime "schedule_time"
  # t.datetime "start_time"
  # t.datetime "stop_time"
  # t.integer  "lsa_server_id"
  # t.integer  "lecture_id"
  # t.integer  "user_id"
  # t.integer  "exercise_id"
  # t.integer  "delayed_job_id"
  # t.datetime "created_at"
  # t.datetime "updated_at"
  
  # Constants

  TYPES = [
    TYPE_PLAGIARISM = 'LsaPlagiarismRun',
    TYPE_SORTING = 'LsaSortingRun',
    TYPE_SCORING = 'LsaScoringRun'
  ]

  STATUS = [
    STATUS_PLANNED = "Planned.",
    STATUS_PROGRESS = "In progress.",
    STATUS_DONE = "Finished."
  ]

  ERRORS = [
    ERROR_SQL = "SQL Error.",
    ERROR_INVALID_LSA_SERVER = "Invalid LSA Server.",
    ERROR_INACTIVE_LSA_SERVER = "LSA Server unreachable.",
    ERROR_INVALID_USER = "Invalid user.",
    ERROR_INVALID_LECTURE = "Invalid lecture.",
    ERROR_MISSING_SUBMISSIONS = "Missing submissions.",
    ERROR_MISSING_IDEAL = "Missing ideal solution.",
    ERROR_INVALID_EXAMPLES = "Invalid example submissions.",
  ]

  # Associations

  belongs_to :user
  belongs_to :lecture
  belongs_to :lsa_server
  belongs_to :delayed_job

  # Scopes

  scope :plagiarism_runs, -> { where(type: TYPE_PLAGIARISM) }
  scope :sorting_runs, -> { where(type: TYPE_SORTING) }
  scope :scoring_runs, -> { where(type: TYPE_SCORING) }

  scope :from_exercise, -> (exercise) { 
    where( exercise_id: exercise.id )
  }
  scope :from_lecture, -> (lecture) {
    joins(:exercise => :lecture).where( :lectures => { :id => lecture.id } )
  }

  scope :datatables, -> {
    joins("LEFT OUTER JOIN users AS dt_users ON lsa_runs.user_id = dt_users.id").
      select("lsa_runs.*").
      select("dt_users.email AS dt_users_email").
      select("dt_users.last_name AS dt_users_last_name").
      select("dt_users.first_name AS dt_users_first_name")
  }
  
  # Methods (Delayed Job Wrapper)

  def start
    self.delay.run if self.valid_basic?
  end

  def start_at(time)
    self.delay(run_at: time).run if self.valid_basic?
  end

  def start_standard
    unless self.schedule_time.nil?
      self.start_at(self.schedule_time)
    else
      self.start
    end
  end

  # Methods (LSA API Setup Wrapper)

  def lsa_get_uri(cmd)
    self.lsa_server.get_uri(cmd) unless self.lsa_server.nil?
  end

  def lsa_get_params
    self.lsa_server.get_params unless self.lsa_server.nil?
  end

  def lsa_get_headers
    self.lsa_server.get_headers unless self.lsa_server.nil?
  end
      
  # Methods (Ready for Action?)

  def valid_basic?
    # Check user
    if self.user.nil?
      self.error_message = ERROR_INVALID_USER
      self.set_stop_time
      self.save
      return false
    end
    # Check lecture.
    if self.lecture.nil?
      self.error_message = ERROR_INVALID_EXERCISE
      self.set_stop_time
      self.save
      return false
    end
    # Check LSA Server
    if self.lsa_server.nil?
      self.error_message = ERROR_INVALID_LSA_SERVER
      self.set_stop_time
      self.save
      return false
    end
    # Check LSA ping
    unless self.lsa_server.ping
      self.error_message = ERROR_INVALID_LSA_SERVER
      self.set_stop_time
      self.save
      return false
    end
    return true
  end

  # Methods (Timer)

  def set_start_time
    self.update_attribute(:start_time, Time.current())
  end

  def set_stop_time
    self.update_attribute(:stop_time, Time.current())
  end

  def time_needed
    (self.stop_time - self.start_time).abs
  end

end
