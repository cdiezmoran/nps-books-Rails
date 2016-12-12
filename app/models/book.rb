class Book

  def initialize(title, author)
    @title = title
    @author = author

    @description = ""
    @isbns = nil
    @img_url = ""
    @nps_score = nil
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
