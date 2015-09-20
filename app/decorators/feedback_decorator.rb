class FeedbackDecorator < ApplicationDecorator

  # Delegation

  delegate_all

  # Associations

  decorates_association :submission

  # Methods

  def points
    return object.grade.to_s + " / " + object.submission.exercise.max_points.to_s
  end

  def points_percent
    number = 100*(object.grade / object.submission.exercise.max_points)
    return number.to_i.to_s + "\%"
  end

  def htmlize_text
    output = "".html_safe
    paragraphs = object.text.split(/\R\R/)
    paragraphs.each do |p|
      output += h.content_tag :p,  p
    end
    return output
  end

end
