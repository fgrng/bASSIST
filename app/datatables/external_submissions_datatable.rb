class ExternalSubmissionsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(exercise, view)
    @view = view
    @exercise = exercise
  end

  def as_json(options = {})
    {
      echo: params[:sEcho].to_i,
      recordsTotal: @exercise.submissions.where(external: true).count,
      recordsFiltered: submissions.to_a.count,
      data: data
    }
  end

	# ---

  private

	# ---

  def data
    decorators = SubmissionDecorator.decorate_collection(submissions)
    decorators.map do |submission|
      [
        ERB::Util.h(submission.dt_comment),
        ERB::Util.h(submission.dt_last_change),
        ERB::Util.h(submission.dt_buttons),
      ]
    end
  end

  def submissions
    submissions ||= fetch_submissions
  end
  
  def fetch_submissions
    submissions = Submission.where(external: true).where("submissions.exercise_id = ?", @exercise.id)
    submissions = submissions.order("#{sort_column} #{sort_direction}")
    if params[:search][:value].present?
      submissions = submissions.where("submissions.comment like :search", search: "%#{params[:search][:value]}%")
    end
    submissions = submissions.page(page).per_page(per_page)
    submissions
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : @exercise.submissions.count
  end

  def sort_column
    columns = %w[submissions.comment submissions.updated_at]
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end
  
end
