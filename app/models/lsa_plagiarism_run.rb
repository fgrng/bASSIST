# coding: utf-8
class LsaPlagiarismRun < LsaRun

	# Attributes
	# 
  # t.string   "type"
  # t.string   "error_message"
  # t.datetime "schedule_time"
  # t.datetime "start_time"
  # t.datetime "stop_time"
	
  # Associations
  
  has_many :lsa_plagiarisms, as: :lsa_run, dependent: :destroy
  has_and_belongs_to_many :exercises, foreign_key: "lsa_run_id"

  # Methods

  def do_in_child
    read, write = IO.pipe

    logger.info "### LSA: Forking process."
    pid = fork do
      read.close
      result = yield
      Marshal.dump(result, write)
      exit!(0) # skips exit handlers.
    end
    logger.info "### LSA: Forking process. Done."
    
    write.close
    logger.info "### LSA: Waiting for forked process."
    logger.info "### LSA: child pid: " + pid.to_s

    result = read.read
    Process.wait(pid)
    raise "child failed" if result.empty?
    Marshal.load(result)
  end

  def run
    # Start progress
    self.error_message = STATUS_PROGRESS
    self.set_start_time
    self.save

    # Check LSA ping
    unless self.lsa_server.ping
      self.error_message = ERROR_INVALID_LSA_SERVER
      self.set_stop_time
      self.save
      return false
    end

    ex_ids = self.exercises.pluck(:id)

    ex_ids.repeated_combination(2).each do |ex_tuple|
			# [1,2] => [(1,1), (1,2), (2,2)]
      success = do_in_child do
        self.compare_exercise_vs_exercise(ex_tuple[0],ex_tuple[1])
      end
      logger.info "### LSA: Forked Process success: " + success.to_s
      break unless success == true
    end

    self.error_message = STATUS_DONE
    self.set_stop_time
    return true
  end

  def compare_exercise_vs_exercise(exercise1_id,exercise2_id)
    logger.info "### LSA Ex_vs_Ex:: Start Ex vs Ex."

    # Prepare DB query
		if exercise1_id == exercise2_id
			sub_ids = Submission.where(exercise_id: exercise1_id).pluck(:id)
			sub_pairs = sub_ids.combination(2)
			# [A,B,C] => [(A,B), (A,C), (B,C)]
		else
			sub1_ids = Submission.where(exercise_id: exercise1_id).pluck(:id)
			sub2_ids = Submission.where(exercise_id: exercise2_id).pluck(:id)
			sub_pairs = sub1_ids.product(sub2_ids)
			# [A,B,C], [X,Y,Z] => [(A,X), (A,Y), (A,Z), (B,X), (B,Y), (B,Z), (C,X), (C,Y), (C,Z)]
		end

		# Prepare HTTP Client
    curl = Curl::Easy.new
    curl.headers = self.lsa_get_headers
    params = self.lsa_get_params

		sub_pairs.each do |pair|
			# Dont compare submission with itself
			next if pair[0] == pair[1]

			# Get Submissions
			sub_a = Submission.find(pair[0])
			sub_b = Submission.find(pair[1])

			# Prepare LsaPlagiarism
			plag = LsaPlagiarism.new
			plag.submission_a = sub_a
			plag.submission_b = sub_b
			plag.lsa_run = self
			plag.save
			
			# Get Cosine
			curl.url = self.lsa_get_uri(LsaServer::COMMAND_COSINE)
      params["text"] = sub_a.text
      params["worksheet"] = sub_b.text
			#
			begin
        curl.post(params.to_json)
      rescue => e
        logger.info "### LSA Ex_vs_Ex:: Curl POST Request error!"
        logger.info "### LSA Ex_vs_Ex:: " + e.message.to_s
        return false
			end
			result = JSON.parse(curl.body)
			#
			plag.cosine = result["cosine"]
			plag.save

			# Get Passages A
			curl.url = self.lsa_get_uri(LsaServer::COMMAND_PLAGIARISM)			
			params.delete("text")
			params.delete("worksheet")
			params["studentText"] = sub_a.text
			params["sourceText"] = sub_b.text
			#
			begin
        curl.post(params.to_json)
      rescue => e
        logger.info "### LSA Ex_vs_Ex:: Curl POST Request error!"
        logger.info "### LSA Ex_vs_Ex:: " + e.message.to_s
        return false
			end
			result = JSON.parse(curl.body)
			#
			passage_collection_a = plag.create_lsa_passage_collection_a
			indices = result["indices"].reverse
			passage_collection_a.passage_count = indices.pop
			passage_collection_a.percentage = indices.pop
			passage_collection_a.submission = sub_a
			passage_collection_a.source = sub_b
			passage_collection_a.save
			plag.save
			until indices.empty?
				passage = passage_collection_a.lsa_passages.new
				passage.last, passage.first = indices.pop(2)
				passage.save
			end

			# Get Passages B
			params["studentText"] = sub_b.text
			params["sourceText"] = sub_a.text
			#
			begin
        curl.post(params.to_json)
      rescue => e
        logger.info "### LSA Ex_vs_Ex:: Curl POST Request error!"
        logger.info "### LSA Ex_vs_Ex:: " + e.message.to_s
        return false
			end
			result = JSON.parse(curl.body)
			#
			passage_collection_b = plag.create_lsa_passage_collection_b
			indices = result["indices"].reverse
			passage_collection_b.passage_count = indices.pop
			passage_collection_b.percentage = indices.pop
			passage_collection_b.submission = sub_b
			passage_collection_b.source = sub_a
			passage_collection_b.save
			plag.save
			until indices.empty?
				passage = passage_collection_b.lsa_passages.new
				passage.last, passage.first = indices.pop(2)
				passage.save
			end

			curl.url = self.lsa_get_uri(LsaServer::COMMAND_COSINES)
			params.delete("studentText")
			params.delete("sourceText")

			# Get Passage Mirrors
			passages_a = Array.new
			passage_collection_a.lsa_passages.each do |pass|
				passages_a << [pass.id, pass.text_snippet]
			end

			passages_b = Array.new
			passage_collection_b.lsa_passages.each do |pass|
				passages_b << [pass.id, pass.text_snippet]
			end

			passages_a.each do |pass_a|
				params["text"] = pass_a[1] 
				params["worksheets"] = passages_b.collect { |x| x[1] } # Array of texts
				params["threshold"] = 0.3 # uneducated guess
				begin
					curl.post(params.to_json)
				rescue => e
					logger.info "### LSA Ex_vs_Ex:: Curl POST Request error!"
					logger.info "### LSA Ex_vs_Ex:: " + e.message.to_s
					return false
				end
				result = JSON.parse(curl.body)
				next if result["indicesValues"].empty?

				max = result["indicesValues"].max_by { |x| x["value"] }
				LsaPassage.find(pass_a[0]).update_attribute(:mirror_id, passages_b[max["index"]][0])
			end unless passages_b.empty?

			passages_b.each do |pass_b|
				params["text"] = pass_b[1] 
				params["worksheets"] = passages_a.collect { |x| x[1] } # Array of texts
				params["threshold"] = 0.3 # uneducated guess
				begin
					curl.post(params.to_json)
				rescue => e
					logger.info "### LSA Ex_vs_Ex:: Curl POST Request error!"
					logger.info "### LSA Ex_vs_Ex:: " + e.message.to_s
					return false
				end
				result = JSON.parse(curl.body)
				next if result["indicesValues"].empty?
				
				max = result["indicesValues"].max_by { |x| x["value"] }
				LsaPassage.find(pass_b[0]).update_attribute(:mirror_id, passages_a[max["index"]][0])
			end unless passages_a.empty?
		end

    logger.info "### LSA Ex_vs_Ex:: Finished."
    return true
  end

end
