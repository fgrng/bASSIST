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

  def name_string
    self.term_string + ": " + object.name
  end
  
  def register_start_string
    date_to_string(object.register_start)
  end 

  def register_stop_string
    date_to_string(object.register_stop)
  end
  
end
