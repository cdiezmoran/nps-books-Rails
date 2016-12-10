class BooksController < ApplicationController

  def index
    response = HTTParty.get('https://www.googleapis.com/books/v1/volumes?q=subject:mystery&printType=books&orderBy=relevance&key:AIzaSyAhhshz7DlcDYgVbDWLCrXZLfMxlVdMYYA')
    body = JSON.parse(response.body)

    @books = body["items"]
    @nps_scores = Array.new

    hydra = Typhoeus::Hydra.new
    @books.each do |book|
      request = Typhoeus::Request.new("https://www.goodreads.com/book/isbn/#{book["volumeInfo"]["industryIdentifiers"][0]["identifier"]}?key=Rf1LgjsOB2cf69K4gMbPkQ", followlocation: true)
      request.on_complete do |response|
        if response.success?
          # Create a hash from the xml data and then symbolize it
          hash = Hash.from_xml(response.body.gsub("\n", ""))
          symbolized_hash = hash.symbolize_keys

          # Get data from
          data = symbolized_hash[:GoodreadsResponse]
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
            @nps_scores << nps_score
          else
            @nps_scores << "This book has no ratings."
          end

        else
          @nps_scores << "Unable to get ratings :/"
        end
      end
      # Add each request to hydra queue
      hydra.queue(request)
    end
    # Run all the requests asynchronousyly
    hydra.run
  end

end
