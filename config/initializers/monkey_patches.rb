class String
  def to_b
    return [true, "true", 1, "1", "T", "t"].include?(self.downcase)
  end
end