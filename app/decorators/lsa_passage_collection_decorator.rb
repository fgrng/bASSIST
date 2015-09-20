class LsaPassageCollectionDecorator < ApplicationDecorator

	# Delegations

	delegate_all

	# Associations

	decorates_association :lsa_plagiarism
	decorates_association :submission
	decorates_association :source

	# Methods

	def percentage_string
		object.percentage.to_i.to_s + "%"
	end

	def htmlize_text
    text = self.submission.text

		start = 0
		output = "".html_safe
		
		self.lsa_passages.order(first: :asc).each do |p|
			unmarked = text[start...p.first]
			marked = text[p.first..p.last].split(/\R\R/)
			start = p.last+1

			output += html_escape(unmarked)
			output += content_tag(:span, marked.shift, :class => "lsa-passage", :passage => p.id , :mirror => p.mirror_id )
			marked.each do |m|
				output += "\n\n".html_safe
				output += content_tag(:span, m, :class => "lsa-passage", :passage => p.id , :mirror => p.mirror_id )
			end
		end

		text = "".html_safe
		output.split(/\R\R/).each do |o|
			text += content_tag(:p, o.html_safe)
		end

		return text
	end
end
