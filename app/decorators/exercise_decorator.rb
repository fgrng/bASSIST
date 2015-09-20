class ExerciseDecorator < ApplicationDecorator

  # Constants

  GROUP_NAMES = [
    GRP_EQUAL="Pflicht",
    GRP_DIFF="Freiwillig",
    GRP_NONE="Keine Gruppe"
  ]

  # Delegations

  delegate_all

  # Associations

  decorates_association :subject

  # Methods

  def name
    return object.subject.name + ' (' + self.type_name + ')'
  end

	def name_lecture
    return self.name + ' - ' + self.subject.lecture.name_string
  end

  def type_name
    object.subject.lecture.exercise_name(object.type)
  end
    
  def group_name
    return GRP_EQUAL if object.group_number <= -1
    return GRP_DIFF if object.group_number == 0
    return ('A'..'ZZ').to_a[object.group_number-1]
  end

  def group_to_student(student)
    if student.group_number == -1 or student.group_number == object.group_number
      return GRP_EQUAL
    end
    return GRP_DIFF
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
