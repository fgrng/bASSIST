class Statement < Exercise

  # Validations
  validates :min_points, :presence => true, numericality: { :greater_than_or_equal_to => 0.0 }
  validates :max_points, :presence => true, numericality: { :greater_than => :min_points }

end
