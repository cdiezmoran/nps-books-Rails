class BooksController < ApplicationController

  def index
    @date = Date.today.end_of_week(:monday)
    if params[:search]
      formatted_search = params[:search].downcase.split(' ').join('+')
      response = Typhoeus.get("https://www.googleapis.com/books/v1/volumes?q=#{formatted_search}&key:AIzaSyAhhshz7DlcDYgVbDWLCrXZLfMxlVdMYYA", followlocation: true)
      body = JSON.parse(response.body)

      responseBooks = body["items"]

      @responseType = "google"

      @books = get_sorted_books(responseBooks, @responseType)
    else
      queryDate = @date.strftime("%Y-%m-%d")
      if params[:date]
        queryDate = params[:date]
        @date = params[:date].to_datetime
      end

      response = Typhoeus.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=ec2d52743558402883a87a233a9b1af7&list=combined-print-and-e-book-fiction&date=#{queryDate}", followlocation: true)
      body = JSON.parse(response.body)

      responseBooks = body["results"]

      @responseType = "nyTimes"

      @books = get_sorted_books(responseBooks, @responseType)
    end
  end

  def show
    response = Typhoeus.get("https://www.googleapis.com/books/v1/volumes?q=#{params[:isbn]}+isbn&key:AIzaSyAhhshz7DlcDYgVbDWLCrXZLfMxlVdMYYA", followlocation: true)

    body = JSON.parse(response.body)

    responseBooks = body["items"]
    volumeInfo = responseBooks[0]["volumeInfo"]
    saleInfo = responseBooks[0]["saleInfo"]

    goodreadsResponse = Typhoeus.get("https://www.goodreads.com/book/isbn/#{params[:isbn].to_i}?key=Rf1LgjsOB2cf69K4gMbPkQ", followlocation: true)

    # Create a hash from the xml data and then symbolize it
    hash = Hash.from_xml(goodreadsResponse.body.gsub("\n", ""))
    symbolized_hash = hash.symbolize_keys

    # Get data from hash
    bookData = symbolized_hash[:GoodreadsResponse]["book"]

    @book = Book.new(params[:title], params[:author])
    @book.nps_score = params[:nps].to_f
    @book.img_url = volumeInfo["imageLinks"]["thumbnail"]

    @book.publisher = volumeInfo["publisher"]
    @book.page_count = volumeInfo["pageCount"]
    @book.categories = volumeInfo["categories"]
    @book.description = bookData["description"]

  end

end

private
def get_sorted_books(responseBooks, responseType)
  books = Array.new

  hydra = Typhoeus::Hydra.new
  responseBooks.each_with_index do |responseBook, index|

    title = ""
    author = ""
    isbns = Array.new
    queryISBN = 0
    if responseType == "nyTimes"
      title = responseBook["book_details"][0]["title"]
      author = responseBook["book_details"][0]["author"]
      isbns = responseBook["isbns"]
      next if isbns.empty?
      queryISBN = isbns[0]["isbn13"].to_i
    elsif responseType == "google"
      title = responseBook["volumeInfo"]["title"]
      author = responseBook["volumeInfo"]["authors"].nil? ? "" : responseBook["volumeInfo"]["authors"][0]
      isbns = responseBook["volumeInfo"]["industryIdentifiers"]

      if !isbns.nil?
        isbns.each do |isbn|
          if isbn["type"] == "ISBN_13"
            queryISBN = isbn["identifier"]
          end
        end
      end
      if queryISBN == 0 && !isbns.nil?
        if isbns[0]["type"] != "ISBN_10"
          next
        end
        queryISBN = isbns[0]["identifier"]
      end
    end

    book = Book.new(title, author)
    book.isbn = queryISBN

    # Create a request for each book
    request = Typhoeus::Request.new("https://www.goodreads.com/book/isbn/#{book.isbn}?key=Rf1LgjsOB2cf69K4gMbPkQ", followlocation: true)

    # Handle the requests
    request.on_complete do |response|
      if response.success?
        # Create a hash from the xml data and then symbolize it
        hash = Hash.from_xml(response.body.gsub("\n", ""))
        symbolized_hash = hash.symbolize_keys

        # Get data from
        data = symbolized_hash[:GoodreadsResponse]
        book.img_url = data["book"]["image_url"]
        rating_dist = data["book"]["work"]["rating_dist"]

        split_rating = rating_dist.split('|')

        # Get total count and check if there are ratings
        total_count = split_rating[5].split(':')[1].to_i
        if total_count != 0
          promoter_count = 0.0
          detractor_count = 0.0

          # Get the count of 5 star ratings
          promoter_count = split_rating[0].split(':')[1].to_i

          # Get the count from 3 to 1 star ratings
          (2..4).each do |i|
            detractor_count += split_rating[i].split(':')[1].to_i
          end

          # Calculate percentages
          promoter_percentage = (promoter_count * 100) / total_count
          detractor_percentage = (detractor_count * 100) / total_count

          # Calculate nps score and append it
          nps_score = promoter_percentage - detractor_percentage
          book.total_reviews = total_count
          book.nps_score = nps_score

        else
          book.nps_score = 0
        end
      else
        next
      end
      books << book
    end
    # Add each request to hydra queue
    hydra.queue(request)
  end
  # Run all the requests
  hydra.run

  # return sorted array
  return books.sort! { |a,b| b.nps_score <=> a.nps_score }
end
