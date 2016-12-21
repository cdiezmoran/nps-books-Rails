module BooksHelper
  def get_prev_date(date)
    date = date - 7
    return date.strftime("%Y-%m-%d")
  end

  def get_next_date(date)
    date = date + 7
    return date.strftime("%Y-%m-%d")
  end

  def get_categories_string(categories)
    str = ""
    categories.each_with_index do |category, index|
      if index == categories.count - 1
        str << category
      else
        str = str + category + ", "
      end
    end
  end
end
