# frozen_string_literal: true

class FieldStruct
  class Error < StandardError
  end
  class TypeError < Error
  end
  class BuildError < Error
  end
end
