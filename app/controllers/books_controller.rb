class BooksController < ApplicationController

  def index
    response = Typhoeus.get('https://api.nytimes.com/svc/books/v3/lists.json?api-key=ec2d52743558402883a87a233a9b1af7&list=combined-print-and-e-book-fiction&date=2016-12-18', followlocation: true)
    body = JSON.parse(response.body)

    responseBooks = body["results"]

    @books = Array.new
    no_isbn_books = Array.new

    hydra = Typhoeus::Hydra.new
    responseBooks.each_with_index do |responseBook, index|
      title = responseBook["book_details"][0]["title"]
      author = responseBook["book_details"][0]["author"]
      book = Book.new(title, author)

      book.isbns = responseBook["isbns"]

      # Check if book has isbn
      if book.isbns.empty?
          no_isbn_books << index
          puts no_isbn_books
        next
      end

      # Create a request for each book
      request = Typhoeus::Request.new("https://www.goodreads.com/book/isbn/#{book.isbns[0]["isbn13"].to_i}?key=Rf1LgjsOB2cf69K4gMbPkQ", followlocation: true)

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
            book.nps_score = nps_score

          else
            book.nps_score = "This book has no ratings."
          end
        else
          book.nps_score = "Unable to get ratings :/"
        end
        @books << book
      end
      # Add each request to hydra queue
      hydra.queue(request)
    end
    # Run all the requests
    hydra.run

    # Sort array
    @books.sort! { |a,b| b.nps_score <=> a.nps_score }
  end

  def show
    response = Typhoeus.get("https://www.goodreads.com/book/isbn/#{params[:isbn].to_i}?key=Rf1LgjsOB2cf69K4gMbPkQ", followlocation: true)
    # Create a hash from the xml data and then symbolize it
    hash = Hash.from_xml(response.body.gsub("\n", ""))
    symbolized_hash = hash.symbolize_keys

    # Get data from
    bookData = symbolized_hash[:GoodreadsResponse]["book"]

    title = bookData["title"]
    author = bookData["authors"]["author"]["name"]
    @book = Book.new(title, author)

    @book.nps_score = params[:nps].to_f
    @book.description = bookData["description"]
    @book.img_url = bookData["image_url"]
  end

end
