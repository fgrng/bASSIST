class LsaPlagiarismsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(collection, view)
    @view = view
    @collection = collection
  end

  def as_json(options = {})
    {
      echo: params[:sEcho].to_i,
      recordsTotal: @collection.lsa_plagiarisms.count,
      recordsFiltered: lsa_plagiarisms.total_entries,
      data: data
    }
  end

	# ---

	private

	# ---

  def data
    lsa_plagiarisms.map do |plag|
      [
        ERB::Util.h(@view.render(
                     :partial => 'lsa_plagiarisms/plagiarism_info_button',
                     :formats => :html,
                     :locals => {:submission => plag.submission_a.decorate,
                                 :ex_name => plag.submission_a.exercise.decorate.name,
                                 :lect_name => plag.submission_a.exercise.subject.lecture.decorate.name } )),
        ERB::Util.h(@view.render(
                     :partial => 'lsa_plagiarisms/plagiarism_info_button',
                     :formats => :html,
                     :locals => {:submission => plag.submission_b.decorate,
                                 :ex_name => plag.submission_b.exercise.decorate.name,
                                 :lect_name => plag.submission_b.exercise.subject.lecture.decorate.name } )),
        ERB::Util.h(plag.decorate.cosine_string),
				ERB::Util.h(plag.decorate.lsa_passage_collection_a.percentage_string),
				ERB::Util.h(plag.decorate.lsa_passage_collection_b.percentage_string),
				ERB::Util.h(plag.decorate.dt_watched),
				ERB::Util.h(@view.render(
                     :partial => 'lsa_plagiarisms/plagiarism_view_button',
                     :formats => :html,
                     :locals => {:plag => plag} )),
				ERB::Util.h(plag.decorate.dt_tr_class),
      ]
    end
  end

  def lsa_plagiarisms
    lsa_plagiarisms ||= fetch_lsa_plagiarisms
  end
  
  def fetch_lsa_plagiarisms
    lsa_plagiarisms = @collection.lsa_plagiarisms.datatables.order("#{sort_column} #{sort_direction}")
    if params[:search][:value].present?
      lsa_plagiarisms = lsa_plagiarisms.where("submission_a_users.email like :search or submission_a_users.first_name like :search or submission_a_users.last_name like :search or submission_b_users.email like :search or submission_b_users.first_name like :search or submission_b_users.last_name like :search", search: "%#{params[:search][:value]}%")
    end
    lsa_plagiarisms = lsa_plagiarisms.page(page).per_page(per_page)
    lsa_plagiarisms
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    columns = %w[submission_a_users.last_name submission_b_users.last_name lsa_plagiarisms.cosine lsa_passage_collections_a.percentage lsa_passage_collections_b.percentage watched]
    columns[params[:order]["0"][:column].to_i]
  end

  def sort_direction
    params[:order]["0"][:dir] == "desc" ? "desc" : "asc"
  end

end
