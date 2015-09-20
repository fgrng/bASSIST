module RolesHelper

  # Not working in nested resources?

  def sti_role_path(type = "role", role = nil, action = nil)
    send "#{format_sti(action, type, role)}_path", role
  end

  def format_sti(action, type, role)
    action || role ? "#{format_action(action)}#{type.underscore}" : "#{type.underscore.pluralize}"
  end

  def format_action(action)
    action ? "#{action}_" : ""
  end

end
