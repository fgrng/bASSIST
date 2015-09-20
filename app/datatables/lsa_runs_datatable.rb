class LsaRunsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(lecture, view)
    @view = view
    @lecture = lecture
  end

  def as_json(options = {})
    {
      echo: params[:sEcho].to_i,
      recordsTotal: @lecture.lsa_runs.count,
      recordsFiltered: lsa_runs.total_entries,
      data: data
    }
  end

	# ---

	private

	# ---

  def data
    decorators = LsaRunDecorator.decorate_collection(lsa_runs)
    decorators.map do |run|
      [
        ERB::Util.h(run.type),
        ERB::Util.h(run.dt_abstract_target),
        ERB::Util.h(run.dt_user),
        ERB::Util.h(run.dt_shedule_time),
        ERB::Util.h(run.dt_startet),
        ERB::Util.h(run.dt_finished),
        ERB::Util.h(run.dt_timer),
        ERB::Util.h(run.dt_status),
      ]
    end
  end

  def lsa_runs
    lsa_runs ||= fetch_lsa_runs
  end
  
  def fetch_lsa_runs
    lsa_runs = LsaRun.where("lsa_runs.lecture_id = ?", @lecture.id).datatables
    lsa_runs = lsa_runs.order("#{sort_column} #{sort_direction}")
    if params[:search][:value].present?
      lsa_runs = lsa_runs.where("dt_users_email like :search or dt_users_first_name like :search or dt_users_last_name like :search", search: "%#{params[:search][:value]}%")
    end
    lsa_runs = LsaRun.from("(#{lsa_runs.to_sql})").
               select("id,created_at,updated_at,type,ideal_solution,first_scored_text,second_scored_text,error_message,exercise_id,first_text_score,second_text_score,lsa_server_id, schedule_time,user_id,start_time,stop_time,lecture_id,delayed_job_id")
    lsa_runs = lsa_runs.page(page).per_page(per_page)
    lsa_runs
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 25
  end

  def sort_column
    columns = %w[lsa_runs.id dt_users_last_name lsa_runs.error_msg lsa_runs.sheduled_at lsa_runs.start_time lsa_runs.stop_time]
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end
end
