class LsaRunDecorator < ApplicationDecorator

  # Delegations

  delegate_all

  # Associations

  decorates_association :lecture
  decorates_association :user

  # Methods

  def timer
    seconds = object.time_needed
    minutes = (seconds/60).to_i
    hours = (seconds/3600).to_i

    minutes = minutes - (hours*60)
    seconds = ( seconds - (hours*3600) - (minutes*60) ).round

    output = "#{seconds}s"
    output = "#{minutes}m " + output if minutes > 0
    output = "#{hours}h " + output if hours > 0
    return output
  end

  def dt_user
    object.user.decorate.dt_list_name
  end
  
  def dt_shedule_time
    handle_empty object.schedule_time do
			date_to_string_short(object.schedule_time)
    end
  end

  def dt_startet
    handle_empty object.start_time do
      date_to_string_short(object.start_time)
    end
  end

  def dt_finished
    handle_empty object.stop_time do
      date_to_string_short(object.stop_time)
    end
  end

  def dt_timer
    if object.stop_time.present? and object.start_time.present?
      return self.timer
    else
      return ""
    end
  end

  def dt_abstract_target
    clone = object
		clone.becomes(clone.type.constantize).decorate.dt_target
  end
  
  def dt_status
    unless object.error_message == LsaRun::STATUS_DONE
      object.error_message
    else
      object.becomes(clone.type.constantize).decorate.dt_results
    end
  end

	# ---

	private

	# ---

  def handle_empty(value)
    if value.present?
      yield
    else
      return ""
    end
  end
  
  
end
