# coding: utf-8
class LsaScoringRun < LsaRun

	# Attributes
	#
  # t.string   "type"
  # t.string   "error_message"
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
  has_many :lsa_scorings, as: :lsa_run, dependent: :destroy

  # Methods
  
  def run
    # Start progress
    self.error_message = STATUS_PROGRESS
    self.set_start_time
    self.save

    # everything ok?
    unless self.valid_scoring?
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
    curl.url = self.lsa_get_uri(LsaServer::COMMAND_SCORING)
    curl.headers = self.lsa_get_headers
		
    params = self.lsa_get_params
    params["idealText"] = self.exercise.ideal_solution
    params["minScore"] = self.exercise.min_points
    params["maxScore"] = self.exercise.max_points
    params["firstScoredText"] = self.first_scored_text
    params["firstScore"] = self.first_text_score
    params["secondScoredText"] = self.second_scored_text
    params["secondScore"] = self.second_text_score
    params["studentTexts"] = submission_texts

		# Oh, by the way:
		# secondScore has to be smaller than firstScore
		# which is not documented in Lsa API from Würzburg

		if params["firstScore"] < params["secondScore"]
			params["firstScore"], params["secondScore"] = params["secondScore"], params["firstScore"]
		end
		
    curl.post(params.to_json)
    gradings = JSON.parse(curl.body)["gradings"]
		
    for index in 0 ... gradings.size
			scoring = self.lsa_scorings.new
			scoring.submission_id = submission_ids[index]
			scoring.grade = gradings[index]
			scoring.save
    end
		
    self.error_message = STATUS_DONE
    self.set_stop_time
    return true
  end

  def valid_scoring?
    # Check exercise ideal solution
    if self.exercise.ideal_solution.blank?
      self.error_message = ERROR_MISSING_IDEAL
      self.save
      return false
    end
    # Check example texts and rank
    if (self.first_scored_text.blank? or
        self.second_scored_text.blank? or
        self.first_text_score.nil? or
        !self.first_text_score.between?(exercise.min_points,exercise.max_points) or
        self.second_text_score.nil? or
        !self.second_text_score.between?(exercise.min_points,exercise.max_points)
       )
      self.error_message = ERROR_INVALID_EXAMPLES
      self.save
      return false
    end
    # Check exercise submissions
    if self.exercise.submissions.count == 0
      self.error_message = ERROR_MISSING_SUBMISSIONS
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

end
