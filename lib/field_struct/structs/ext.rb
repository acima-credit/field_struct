# frozen_string_literal: true

class Module
  # Extends any Module to include _field_struct?_ method.
  # Returns false by default
  #
  # @return [false]
  def field_struct?
    false
  end
end

class Class
  # Extends any Class to include _field_struct?_ method.
  # Returns false by default
  #
  # @return [false]
  def field_struct?
    false
  end
end

class Object
  # Extends any Object to include _field_struct?_ method.
  # Delegates to the object's class.
  #
  # @return [true, false]
  def field_struct?
    self.class.field_struct?
  end
end
