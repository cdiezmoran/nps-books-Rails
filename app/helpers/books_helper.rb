module BooksHelper
  def get_prev_date(date)
    date = date - 7
    return date.strftime("%Y-%m-%d")
  end

  def get_next_date(date)
    date = date + 7
    return date.strftime("%Y-%m-%d")
  end
end
