class LsaSortingRun < LsaRun

	# Attributes
	#
  # t.string   "type"
  # t.string   "error_message"
  # t.integer  "lsa_server_id"
  # t.datetime "schedule_time"
  # t.text     "ideal_solution"
  # t.text     "first_scored_text"
  # t.text     "second_scored_text"
  # t.float    "first_text_score"
  # t.float    "second_text_score"
  # t.datetime "start_time"
  # t.datetime "stop_time"

	# Associations

  belongs_to :exercise
  has_many :lsa_sortings, as: :lsa_run, dependent: :destroy

  # Methods

  def run
    # Start progress
    self.error_message = STATUS_PROGRESS
    self.set_start_time
    self.save

    unless self.lsa_server.ping
      self.error_message = ERROR_INVALID_LSA_SERVER
      self.set_stop_time
      self.save
      return false
    end

    submissions = self.exercise.submissions.pluck(:id, :text)
    submission_ids = Array.new
    submission_texts = Array.new
    submissions.each do |sub|
      submission_ids.push(sub[0])
      submission_texts.push(sub[1])
    end

    curl = Curl::Easy.new
    curl.url = self.lsa_get_uri(LsaServer::COMMAND_SORTING)
    curl.headers = self.lsa_get_headers
    params = self.lsa_get_params

		params["idealText"] = self.exercise.ideal_solution
    params["studentTexts"] = submission_texts

    curl.post(params.to_json)
    indices = JSON.parse(curl.body)["indices"]

    for index in 0 ... indices.size
			sorting = self.lsa_sortings.new
			sorting.submission_id = submission_ids[indices[index]]
			sorting.position = index
			sorting.save
    end
   
    self.error_message = STATUS_DONE
    self.set_stop_time
    return true
  end

end
