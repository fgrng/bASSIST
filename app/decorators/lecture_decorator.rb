class LectureDecorator < ApplicationDecorator

  # Constants

  WINTER_TERM = "Wintersemester"
  SUMMER_TERM = "Sommersemester"

  # Delegations

  delegate_all

  # Associations

  # Methods

  def term_year
    object.year.year
  end

  def term_string
    string = WINTER_TERM if object.term == "w"
    string = SUMMER_TERM if object.term == "s"
    string + " " + self.term_year.to_s
  end

  def term_string_short
    string = object.term.capitalize + "S"
    string += self.term_year.to_s[-2..-1]
    string += ": "
    string += object.name
    return string
  end

  def name_string
    self.term_string + ": " + object.name
  end

  def register_start_string
    date_to_string(object.register_start)
  end

  def register_stop_string
    date_to_string(object.register_stop)
  end

  def import_options
    options = [["(nicht verwenden)", "ignore"]]
    options << ["Eindeutige Personenkennung", "id"]
    Exercise::TYPE_STATEMENTS.each do |type|
      options << ["Bewerteter Aufgabentyp: #{object.exercise_name(type)}", type]
    end
    Exercise::TYPE_REFLECTIONS.each do |type|
      options << ["Unbewerteter Aufgabentyp: #{object.exercise_name(type)}", type]
    end
    return options
  end

end
