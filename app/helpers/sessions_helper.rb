module SessionsHelper

  # Session - Current User

  def sign_in(user)
    if user.present?
      # Session Fixation - Countermeasure
      # reset_session

      session[:current_user_id] = user.id
      self.current_user = user
      return true
    else
      return false
    end
  end

  def signed_in?
    !self.current_user.nil?
  end

  def sign_out
    current_user.update_attribute(:active_lecture, active_lecture) if signed_in?
    session.clear if session
    self.current_user = nil    
    self.deselect_lecture
    
    # Session Fixation - Countermeasure
    # reset_session
  end

  def current_user=(user)
    @_current_user = user
  end

  def current_user
    @_current_user || User.find_by_id(session[:current_user_id])
  end

  # Session - Active Lecture
  
  def select_lecture(lecture)
    session[:active_lecture] = lecture.id
    current_user.update_attribute(:active_lecture, active_lecture)
    self.active_lecture = lecture
  end

  def deselect_lecture
    session.delete(:active_lecture)
    self.active_lecture = nil
  end

  def active_lecture=(lecture)
    @_active_lecture = lecture
  end

  def active_lecture
    if ret = @_active_lecture 
      return ret.decorate
    end
    if session[:active_lecture]
      lecture = Lecture.find_by_id(session[:active_lecture])
      unless lecture.nil?
        return lecture.decorate
      else
        return nil
      end
    end
    if ret = current_user.active_lecture
      return ret.decorate
    end
    return nil
  end

end
