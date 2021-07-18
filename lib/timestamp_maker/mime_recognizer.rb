# frozen_string_literal: true

module TimestampMaker
  module MimeRecognizer
    def self.recognize(path)
      Marcel::MimeType.for(Pathname.new(path))
    end
  end
end
