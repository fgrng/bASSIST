class LsaPlagiarism < ApplicationRecord

	# Attributes
	#
  # t.integer "lsa_run_id"
  # t.string  "lsa_run_type"
  # t.float   "cosine"
	# t.integer "watched",

	# Associations

	belongs_to :lsa_run, polymorphic: true

  belongs_to :submission_a, class_name: "Submission"
  belongs_to :submission_b, class_name: "Submission"

  belongs_to :lsa_passage_collection_a, class_name: "LsaPassageCollection", dependent: :destroy
  belongs_to :lsa_passage_collection_b, class_name: "LsaPassageCollection", dependent: :destroy
	
  scope :ordered, -> { 
    order('cosine DESC')
  }

  # Scopes

  scope :datatables, -> { 
    joins("INNER JOIN submissions AS submissions_a ON submissions_a.id = lsa_plagiarisms.submission_a_id").
      joins("LEFT OUTER JOIN roles AS submission_a_students ON submission_a_students.id = submissions_a.student_id").
      joins("LEFT OUTER JOIN users AS submission_a_users ON submission_a_users.id = submission_a_students.user_id").
      joins("INNER JOIN submissions AS submissions_b ON submissions_b.id = lsa_plagiarisms.submission_b_id").
      joins("LEFT OUTER JOIN roles AS submission_b_students ON submission_b_students.id = submissions_b.student_id").
      joins("LEFT OUTER JOIN users AS submission_b_users ON submission_b_users.id = submission_b_students.user_id").
			joins("INNER JOIN lsa_passage_collections AS lsa_passage_collections_a ON lsa_passage_collections_a.id = lsa_plagiarisms.lsa_passage_collection_a_id").
			joins("INNER JOIN lsa_passage_collections AS lsa_passage_collections_b ON lsa_passage_collections_b.id = lsa_plagiarisms.lsa_passage_collection_b_id").
      select("lsa_plagiarisms.id,lsa_plagiarisms.cosine,lsa_plagiarisms.watched,lsa_plagiarisms.submission_a_id,lsa_plagiarisms.submission_b_id,lsa_plagiarisms.lsa_passage_collection_a_id,lsa_plagiarisms.lsa_passage_collection_b_id,submission_a_users.last_name,submission_a_users.first_name,submission_a_users.email,submission_b_users.last_name,submission_b_users.first_name,submission_a_users.email,lsa_passage_collections_a.percentage,lsa_passage_collections_b.percentage")
  }

	# Methods

	# Fixing polymorphic + STI
  def lsa_run_type=(sType)
     super(sType.to_s.classify.constantize.base_class.to_s)
  end

end
