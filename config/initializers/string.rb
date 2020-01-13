class String
  def strip_all_spaces
    gsub(/\A\p{Space}+|\p{Space}+\z/, "")
  end
end
