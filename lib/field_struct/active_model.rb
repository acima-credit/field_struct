# frozen_string_literal: true

module FieldStruct
  module_function

  def known_active_model_types
    ::ActiveModel::Type.registry.send(:registrations)
  end

  def known_active_model_names
    known_active_model_types
      .map { |type| ::ActiveModel::VERSION::MAJOR > 6 ? type.first : type.send(:name) }
  end
end
