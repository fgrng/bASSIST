module SessionsHelper

  # Session - Current User
  
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies[:remember_token] = { value: remember_token }
    user.update_attribute(:remember_token, User.hash(remember_token))
    self.current_user = user
  end

  def signed_in?
    !self.current_user.nil?
  end

  def sign_out
    current_user.update_attribute(:remember_token, User.hash(User.new_remember_token))
    current_user.update_attribute(:active_lecture, active_lecture)
    cookies.delete(:remember_token)
    cookies.delete(:active_lecture)
    self.deselect_lecture
    self.current_user = nil
  end

  def current_user=(user)
    @_current_user = user
  end

  def current_user
    remember_token = User.hash(cookies[:remember_token])
    @_current_user ||= User.find_by(remember_token: remember_token)
  end

  # Session - Active Lecture
  
  def select_lecture(lecture)
    cookies[:active_lecture] = { value: lecture.id }
    current_user.update_attribute(:active_lecture, active_lecture)
    self.active_lecture = lecture
  end

  def deselect_lecture
    cookies.delete(:active_lecture)
    self.active_lecture = nil
  end

  def active_lecture=(lecture)
    @_active_lecture = lecture
  end

  def active_lecture
    if ret = @_active_lecture 
      return ret.decorate
    end
    if cookies[:active_lecture]
      lecture = Lecture.find_by_id(cookies[:active_lecture])
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
