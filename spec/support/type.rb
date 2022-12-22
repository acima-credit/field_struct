# frozen_string_literal: true

module TypeHelpers
  extend RSpec::Core::SharedContext

  let(:attribute) { FieldedStruct::Metadata::Attribute.new attr_options }
  let(:attribute_name) { 'some_field' }
  let(:attribute_type) { :some_type }
  let(:coercible) { false }
  let(:base_attr_options) { { name: attribute_name, type: attribute_type, coercible: coercible } }
  let(:attr_options) { base_attr_options }

  let(:bd_value) { BigDecimal('12.34') }
  let(:time_value) { Time.zone.parse('2020-03-01 04:15:25 -0700') }
  let(:datetime_value) { DateTime.parse('2020-03-01 04:15:25 -0700') }
  let(:date_value) { Date.parse('2020-03-01') }
  # let(:datetime_value) { time_value.to_datetime }
  # let(:date_value) { time_value.to_date }
end

RSpec.configure do |config|
  config.include TypeHelpers, type: :type
end
