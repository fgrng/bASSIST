class ApplicationDecorator < Draper::Decorator

  # Paginating on Decorator Collections
  # https://github.com/drapergem/draper/issues/429
  def self.collection_decorator_class
    PaginatingDecorator
  end

  # Methods
  
  def date_to_string(date)
    I18n.localize(date, format: :long)
  end

  def date_to_string_short(date)
    I18n.localize(date, format: :short)
  end 

end
