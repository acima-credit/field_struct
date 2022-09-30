# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldStruct::Types::Date, type: :type do
  describe 'class' do
    it { expect(described_class.ancestors).to include FieldStruct::Types::Base }
    it { expect(described_class.type).to eq :date }
    it { expect(described_class.base_type).to eq Date }
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
        it { expect(subject.coercible?(date_value)).to eq true } # Date
        it { expect(subject.coercible?(datetime_value)).to eq false } # DateTime
        it { expect(subject.coercible?(time_value)).to eq false } # Time
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
        it { expect(subject.coerce(date_value)).to eq date_value } # Date
        it { expect(subject.coerce(datetime_value)).to eq nil } # DateTime
        it { expect(subject.coerce(time_value)).to eq nil } # Time
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
        it { expect(subject.coercible?(datetime_value)).to eq true } # DateTime
        it { expect(subject.coercible?(time_value)).to eq true } # Time
        it { expect(subject.coercible?(true)).to eq false } # Boolean
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq nil } # Integer
        it { expect(subject.coerce(3)).to eq nil }
        it { expect(subject.coerce(-3)).to eq nil }
        it('works', :focus) { expect(subject.coerce('0')).to eq nil } # String
        it { expect(subject.coerce('3')).to eq nil }
        it { expect(subject.coerce('-3')).to eq nil }
        it { expect(subject.coerce('wibble')).to eq nil }
        it { expect(subject.coerce('2020-03-01 15:10:14 -0600')).to eq date_value }
        it { expect(subject.coerce('2020-03-01 15:10:14')).to eq date_value }
        it { expect(subject.coerce('01/03/2020')).to eq date_value }
        it { expect(subject.coerce(0.0)).to eq nil } # Float
        it { expect(subject.coerce(3.0)).to eq nil }
        it { expect(subject.coerce(-3.0)).to eq nil }
        it { expect(subject.coerce(bd_value)).to eq nil } # Decimal
        it { expect(subject.coerce(date_value)).to eq date_value } # Date
        it { expect(subject.coerce(datetime_value)).to eq date_value } # DateTime
        it { expect(subject.coerce(time_value)).to eq date_value } # Time
        it { expect(subject.coerce(true)).to eq nil } # Boolean
        context 'with custom format' do
          context 'd-m-y' do
            let(:attr_options) { base_attr_options.update parse_format: [/\A(\d{4})-(\d\d)-(\d\d)\z/, 3, 2, 1] }
            it { expect(subject.coerce('01-03-2020')).to eq date_value }
          end
        end
        context 'with class date format' do
          context 'd-m-y' do
            before { described_class.parse_formats[:dmy] = [/\A(\d{4})-(\d\d)-(\d\d)\z/, 3, 2, 1] }
            it { expect(subject.coerce('01-03-2020')).to eq date_value }
            after { described_class.parse_formats.delete :dmy }
          end
        end
      end
    end
  end
end
