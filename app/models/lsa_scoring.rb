class LsaScoring < ActiveRecord::Base

	# Attributes
	#
  # t.float    "grade"
  # t.string   "lsa_run_type"

	# Associations

	belongs_to :lsa_run, polymorphic: true
  belongs_to :submission

	# Scopes
	
	scope :ordered, -> { 
    order('grade DESC')
  }

	# Methods

	# Fixing polymorphic + STI
  def lsa_run_type=(sType)
     super(sType.to_s.classify.constantize.base_class.to_s)
  end
  
end
