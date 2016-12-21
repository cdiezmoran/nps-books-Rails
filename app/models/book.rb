class Book

  def initialize(title, author)
    @title = title
    @author = author

    @description = ""
    @isbn = nil
    @img_url = ""
    @nps_score = 0
    @google_buy_url = nil
  end

  def nps_color_class
    if @nps_score >= -5 and @nps_score <= 5
      return 'regular-nps'
    elsif @nps_score > 5 and @nps_score <= 25
      return 'good-nps'
    elsif @nps_score > 25
      return 'great-nps'
    elsif @nps_score < -5 and @nps_score >= -25
      return 'bad-nps'
    else
      return 'awful-nps'
    end
  end

  def nps_description_word
    if @nps_score >= -5 and @nps_score <= 5
      return 'Regular'
    elsif @nps_score > 5 and @nps_score <= 25
      return 'Good'
    elsif @nps_score > 25
      return 'Great'
    elsif @nps_score < -5 and @nps_score >= -25
      return 'Bad'
    else
      return 'Really Bad'
    end
  end

  def title
    @title
  end

  def author
    @author
  end

  def description
    @description
  end

  def description= description
    @description = description
  end

  def isbn
    @isbn
  end

  def isbn= isbn
    @isbn = isbn
  end

  def img_url
    @img_url
  end

  def img_url= img_url
    @img_url = img_url
  end

  def nps_score
    @nps_score
  end

  def nps_score= nps_score
    @nps_score = nps_score
  end

  def publisher
    @publisher
  end

  def publisher= publisher
    @publisher = publisher
  end

  def page_count
    @page_count
  end

  def page_count= page_count
    @page_count = page_count
  end

  def categories
    @categories
  end

  def categories= categories
    @categories = categories
  end

end
