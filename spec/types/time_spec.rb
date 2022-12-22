# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldedStruct::Types::Time, type: :type do
  describe 'class' do
    it { expect(described_class.ancestors).to include FieldedStruct::Types::Base }
    it { expect(described_class.type).to eq :time }
    it { expect(described_class.base_type).to eq [::Time, ::ActiveSupport::TimeWithZone] }
  end
  describe 'instance' do
    subject { described_class.new attribute }
    let(:attribute_type) { :date }
    context 'when non-coercible' do
      let(:coercible) { false }
      context '#coercible?' do
        it { expect(subject.coercible?(nil)).to eq false } # Nil
        it { expect(subject.coercible?(0)).to eq false } # Integer
        it { expect(subject.coercible?(3)).to eq false }
        it { expect(subject.coercible?(-3)).to eq false }
        it { expect(subject.coercible?(:some_symbol)).to eq false } # Symbol
        it { expect(subject.coercible?('0')).to eq false } # String
        it { expect(subject.coercible?('3')).to eq false }
        it { expect(subject.coercible?('-3')).to eq false }
        it { expect(subject.coercible?('wibble')).to eq false }
        it { expect(subject.coercible?(0.0)).to eq false } # Float
        it { expect(subject.coercible?(3.0)).to eq false }
        it { expect(subject.coercible?(-3.0)).to eq false }
        it { expect(subject.coercible?(true)).to eq false } # Boolean
        it { expect(subject.coercible?(false)).to eq false }
        it { expect(subject.coercible?(bd_value)).to eq false } # Decimal
        it { expect(subject.coercible?(date_value)).to eq false } # Date
        it { expect(subject.coercible?(datetime_value)).to eq false } # Time
        it { expect(subject.coercible?(time_value)).to eq true } # Time
        it { expect(subject.coercible?(true)).to eq false } # Boolean
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq nil } # Integer
        it { expect(subject.coerce(3)).to eq nil }
        it { expect(subject.coerce(-3)).to eq nil }
        it { expect(subject.coerce('0')).to eq nil } # String
        it { expect(subject.coerce('3')).to eq nil }
        it { expect(subject.coerce('-3')).to eq(nil) }
        it { expect(subject.coerce('wibble')).to eq nil }
        it { expect(subject.coerce(0.0)).to eq nil } # Float
        it { expect(subject.coerce(3.0)).to eq nil }
        it { expect(subject.coerce(-3.0)).to eq(nil) }
        it { expect(subject.coerce(bd_value)).to eq nil } # Decimal
        it { expect(subject.coerce(date_value)).to eq nil } # Date
        it { expect(subject.coerce(datetime_value)).to eq nil } # Time
        it { expect(subject.coerce(time_value)).to eq time_value } # Time
        it { expect(subject.coerce(true)).to eq nil } # Boolean
      end
    end
    context 'when coercible' do
      let(:coercible) { true }
      context '#coercible?' do
        it { expect(subject.coercible?(nil)).to eq false } # Nil
        it { expect(subject.coercible?(0)).to eq false } # Integer
        it { expect(subject.coercible?(3)).to eq false }
        it { expect(subject.coercible?(-3)).to eq false }
        it { expect(subject.coercible?(:some_symbol)).to eq false } # Symbol
        it { expect(subject.coercible?('0')).to eq true } # String
        it { expect(subject.coercible?('3')).to eq true }
        it { expect(subject.coercible?('-3')).to eq true }
        it { expect(subject.coercible?('wibble')).to eq true }
        it { expect(subject.coercible?(0.0)).to eq false } # Float
        it { expect(subject.coercible?(3.0)).to eq false }
        it { expect(subject.coercible?(-3.0)).to eq false }
        it { expect(subject.coercible?(true)).to eq false } # Boolean
        it { expect(subject.coercible?(false)).to eq false }
        it { expect(subject.coercible?(bd_value)).to eq false } # Decimal
        it { expect(subject.coercible?(date_value)).to eq true } # Date
        it { expect(subject.coercible?(datetime_value)).to eq true } # Time
        it { expect(subject.coercible?(time_value)).to eq true } # Time
        it { expect(subject.coercible?(true)).to eq false } # Boolean
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq nil } # Integer
        it { expect(subject.coerce(3)).to eq nil }
        it { expect(subject.coerce(-3)).to eq nil }
        it { expect(subject.coerce('0')).to eq nil } # String
        it { expect(subject.coerce('3')).to eq nil }
        it { expect(subject.coerce('-3')).to eq nil }
        it { expect(subject.coerce('wibble')).to eq nil }
        it { expect(subject.coerce('2020-03-01T04:15:25+00:00')).to eq time_value }
        it { expect(subject.coerce('Sun, 01 Mar 2020 04:15:25 -0700').to_s).to eq time_value.to_s }
        it { expect(subject.coerce('Sun, 01 Mar 2020 04:15:25 -0600').to_s).to eq '2020-03-01 03:15:25 -0700' }
        it { expect(subject.coerce('Sun, 01 Mar 2020 04:15:25 -0500').to_s).to eq '2020-03-01 02:15:25 -0700' }
        it { expect(subject.coerce('Sun, 01 Mar 2020 04:15:25 -0400').to_s).to eq '2020-03-01 01:15:25 -0700' }
        it { expect(subject.coerce('2020-03-01 04:15:25')).to eq time_value }
        it { expect(subject.coerce('01/03/2020').to_s).to eq '2020-03-01 00:00:00 -0700' }
        it { expect(subject.coerce(0.0)).to eq nil } # Float
        it { expect(subject.coerce(3.0)).to eq nil }
        it { expect(subject.coerce(-3.0)).to eq nil }
        it { expect(subject.coerce(bd_value)).to eq nil } # Decimal
        it { expect(subject.coerce(date_value).to_s).to eq '2020-03-01 00:00:00 -0700' } # Date
        it { expect(subject.coerce(datetime_value)).to eq time_value } # Time
        it { expect(subject.coerce(time_value).to_s).to eq '2020-03-01 04:15:25 -0700' } # Time
        it { expect(subject.coerce(true)).to eq nil } # Boolean
        context 'with custom format' do
          context 'y-d-m h:m:s' do
            let(:attr_options) do
              base_attr_options.update parse_format: [/\A(\d{4})-(d{2})-(d{2}) (d{2}):(d{2}):(d{2})\z/, 1, 2, 3, 4, 5,
                                                      6]
            end
            it { expect(subject.coerce('2020-03-01 04:15:25')).to eq time_value }
          end
        end
        context 'with class date format' do
          context 'd-m-y' do
            before do
              described_class.parse_formats[:dmy] = [/\A(\d{4})-(d{2})-(d{2}) (d{2}):(d{2}):(d{2})\z/, 1, 2, 3, 4, 5, 6]
            end
            it { expect(subject.coerce('2020-03-01 04:15:25')).to eq time_value }
            after { described_class.parse_formats.delete :dmy }
          end
        end
      end
    end
  end
end
