class BooksController < ApplicationController

  def index
    response = HTTParty.get('https://www.googleapis.com/books/v1/volumes?q=subject:fantasy&printType=books&orderBy=relevance&key:AIzaSyAhhshz7DlcDYgVbDWLCrXZLfMxlVdMYYA')
    body = JSON.parse(response.body)

    @books = body["items"]
    @nps_scores = Array.new

    hydra = Typhoeus::Hydra.new
    @books.each do |book|
      request = Typhoeus::Request.new("https://www.goodreads.com/book/isbn/#{book["volumeInfo"]["industryIdentifiers"][0]["identifier"]}?key=Rf1LgjsOB2cf69K4gMbPkQ", followlocation: true)
      request.on_complete do |response|
        hash = Hash.from_xml(response.body.gsub("\n", ""))
        symbolized_hash = hash.symbolize_keys

        data = symbolized_hash[:GoodreadsResponse]
        rating_dist = data["book"]["work"]["rating_dist"]

        @nps_scores << rating_dist
      end
      hydra.queue(request)
    end
    hydra.run
  end

end
