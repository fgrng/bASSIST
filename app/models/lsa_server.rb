class LsaServer < ApplicationRecord

  # Attributes
  #
  # t.string   "name"
  # t.string   "json_url"
  # t.string   "rmi_url"
  # t.integer  "rmi_port"
  # t.integer  "json_port"
  # t.string   "json_path"

  # Contants

  COMMANDS = [
    COMMAND_PING = 'SWping',
    COMMAND_PLAGIARISM = 'SWgetPlagiarism',
    COMMAND_SORTING = 'SWgetSorted',
    COMMAND_SCORING = 'SWgetSingleScores',
    COMMAND_COSINE = 'SWgetCosine',
    COMMAND_COSINES = 'SWgetCosines',
  ]

  # Associations

  has_many :lsa_runs

  # Validations

  validates :json_url, :presence => true
  validates :json_port, :presence => true

  validates :json_path, :presence => true
  validate :path_has_correct_format

  validates :rmi_url, :presence => true
  validates :rmi_port, :presence => true

  def path_has_correct_format
    if json_path.nil?
      errors.add(:term, "can't be blank.")
    elsif json_path[0] != "/"
      errors.add(:term, "must start with '/'.")
    end
  end

  # Methods

  # LSA API Setup

  def get_uri(cmd)
    uri = self.json_url
    uri += ":"
    uri += self.json_port.to_s
    uri += "/swJSON/"
    uri += cmd
    return uri
  end

  def get_params
    params = Hash.new
    params["rmiHost"] = self.rmi_url
    params["rmiPort"] = self.rmi_port.to_s
    return params
  end

  def get_headers
    headers = Hash.new
    headers['Content-Type'] = 'application/json; charset=utf-8'
    headers['charset'] = 'utf-8'
    return headers
  end

  # LSA API Functions

  def ping
    curl = Curl::Easy.new
    curl.url = self.get_uri(COMMAND_PING)
    curl.headers = self.get_headers
    # Send http request
    begin
      curl.post(self.get_params.to_json)
    rescue
      return false
    end
    # Parse response body
    unless curl.body.nil?
      begin
        return JSON.parse(curl.body)["isConnection"]
      rescue
        return false
      end
    end
    return false
  end

  # Methods - LSA

  def self.lsa_sort_submissions_from_exercise(exercise,user,lsa_server)
    # Needed parameters
    # - "idealText": ideal solution
    # - "studentTexts": array of texts

    lsa_run = LsaSortingRun.new
    lsa_run.error_message = "In Progress."
    lsa_run.save

    indices = client.getSorted(exercise.ideal_solution,submissions_texts)

    for index in 0 ... indices["indices"].size
      sub = Submission.find(submissions_id[index])
      LsaSorting.create(
        lsa_run: lsa_run,
        submission_id: sub.id,
        position: indices["indices"][index]
      )
    end

    lsa_run.error_message = "Finished."
    lsa_run.save

  end

end
