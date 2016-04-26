class UsersDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      echo: params[:sEcho].to_i,
      recordsTotal: User.verified.count,
      recordsFiltered: users.total_entries,
      data: data
    }
  end

	# ---

	private

	# ---

  def data
    users.map do |user|
      [
        ERB::Util.h(user.id),
        ERB::Util.h(user.last_name),
        ERB::Util.h(user.first_name),
        ERB::Util.h(user.email),
				ERB::Util.h(@view.render(:partial => 'users/index/button_email_valid', :formats => :html, :locals => {:user => user} )),
        ERB::Util.h(@view.render(:partial => 'users/index/button_add_to_lecture', :formats => :html, :locals => {:user => user} ))
      ]
    end
  end

  def users
    users ||= fetch_users
  end
  
  def fetch_users
    users = User.all.order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:search][:value].present?
      users = users.where("email like :search or first_name like :search or last_name like :search", search: "%#{params[:search][:value]}%")
    end
    users
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : User.verified.count
  end

  def sort_column
    columns = %w[id last_name first_name email validated]
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end
  
end
