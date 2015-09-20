class PaginatingDecorator < Draper::CollectionDecorator

  # https://github.com/drapergem/draper/issues/429

  # support for will_paginate
  delegate :current_page, :total_entries, :total_pages, :per_page, :offset

  # allow decoration of collection
  delegate :decorate

end
