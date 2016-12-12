class Book

  def initialize(title, author)
    @title = title
    @author = author

    @description = ""
    @isbns = nil
    @img_url = ""
    @nps_score = 0
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

  def isbns
    @isbns
  end

  def isbns= isbns
    @isbns = isbns
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

end
