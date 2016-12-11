class Book

  def initialize(title, author, isbns)
    @title = title
    @author = author
    @isbns = isbns

    @img_url = ""
    @small_img_url = ""
    @nps_score = nil
  end

  def title
    @title
  end

  def author
    @author
  end

  def isbns
    @isbns
  end

  def img_url
    @img_url
  end

  def img_url= img_url
    @img_url = img_url
  end

  def small_img_url
    @small_img_url
  end

  def small_img_url= img_url
    @small_img_url = img_url
  end

  def nps_score
    @nps_score
  end

  def nps_score= nps_score
    @nps_score = nps_score
  end

end
