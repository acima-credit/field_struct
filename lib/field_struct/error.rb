# frozen_string_literal: true

module FieldStruct
  class Error < StandardError
  end
  class TypeError < Error
  end
  class AttributeOptionError < Error
  end
  class BuildError < Error
  end
end
