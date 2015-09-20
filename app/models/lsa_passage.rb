class LsaPassage < ActiveRecord::Base

	# Attributes
	# 
	# t.integer "first"
  # t.integer "last"
  # t.integer "mirror_id"
  # t.integer "lsa_passage_collection_id"

	# Associations

  belongs_to :lsa_passage_collection
	belongs_to :mirror, class_name: "LsaPassage"
  
	# Methods

	def text_snippet
		self.lsa_passage_collection.submission.text[self.first..self.last]
	end

end
