module ExercisesHelper

  # Not working in nested resources?

  def sti_exercise_path(type = "exercise", exercise = nil, action = nil, parent = nil)
    send "#{format_sti(action, type, exercise)}_path", exercise
  end

  def format_sti(action, type, exercise)
    action || exercise ? "#{format_action(action)}#{type.underscore}" : "#{type.underscore.pluralize}"
  end

  def format_action(action)
    action ? "#{action}_" : ""
  end

end
