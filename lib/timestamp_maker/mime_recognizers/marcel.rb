# frozen_string_literal: true

require 'marcel'

class TimestampMaker
  module MimeRecognizers
    class Marcel
      def recognize(path)
        ::Marcel::MimeType.for(Pathname.new(path))
      end
    end
  end
end
