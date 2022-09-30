# frozen_string_literal: true

module TypeHelpers
  extend RSpec::Core::SharedContext

  let(:attribute) { FieldStruct::Metadata::Attribute.new attr_options }
  let(:attribute_name) { 'some_field' }
  let(:attribute_type) { :some_type }
  let(:coercible) { false }
  let(:base_attr_options) { { name: attribute_name, type: attribute_type, coercible: coercible } }
  let(:attr_options) { base_attr_options }

  let(:bd_value) { BigDecimal('12.34') }
  let(:date_value) { Date.parse('2020-03-01') }
  let(:datetime_value) { DateTime.parse('2020-03-01 04:15:25') }
  let(:time_value) { Time.parse('2020-03-01 04:15:25') }
end

RSpec.configure do |config|
  config.include TypeHelpers, type: :type
end
