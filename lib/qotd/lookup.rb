module Qotd
  module Lookup
    extend self

    def quotes
      Qotd::QUOTES
    end

    def quote_of_the_day(author_id: author_id)
      begin
        quotes[author_id][_index_for_today]
      rescue
        false
      end
    end

    def _number_of_quotes
      quotes.length
    end

    def _index_for_today
      _day_of_year % _number_of_quotes
    end

    def _day_of_year
      Time.now.yday
    end
  end
end

