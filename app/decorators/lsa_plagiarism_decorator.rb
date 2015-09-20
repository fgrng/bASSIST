# coding: utf-8
class LsaPlagiarismDecorator < ApplicationDecorator

  # Delegations

  delegate_all

	# Associations

	decorates_association :lsa_run
	decorates_association :submission_a
	decorates_association :submission_b
	decorates_association :lsa_passage_collection_a
	decorates_association :lsa_passage_collection_b

	# Methods

	def arccos
		Math::acos(self.cosine)
	end

	def progress_bar_value
		( ( (-1)*self.arccos + Math::PI ) / Math::PI ) * 100
	end

	def cosine_string
		self.cosine.round(4).to_s
	end

	# Datatables

  def dt_watched
		return "Verdächtig" if object.watched < 0
		return "Unbedenklich" if object.watched > 0
		return ""
  end

	def dt_tr_class
		return "danger" if object.watched < 0
		return "success" if object.watched > 0
		return "none"
  end

end
