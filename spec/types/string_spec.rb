# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldStruct::Types::String, type: :type do
  describe 'class' do
    it { expect(described_class.ancestors).to include FieldStruct::Types::Base }
    it { expect(described_class.type).to eq :string }
    it { expect(described_class.base_type).to eq String }
  end
  describe 'instance' do
    subject { described_class.new attribute }
    let(:attribute_type) { :string }
    context 'when non-coercible' do
      let(:coercible) { false }
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
        it { expect(subject.coercible?(date_value)).to eq false } # Date
        it { expect(subject.coercible?(datetime_value)).to eq false } # DateTime
        it { expect(subject.coercible?(time_value)).to eq false } # Time
        it { expect(subject.coercible?(true)).to eq false } # Boolean
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq nil } # Integer
        it { expect(subject.coerce(3)).to eq nil }
        it { expect(subject.coerce(-3)).to eq(nil) }
        it { expect(subject.coerce(:some_symbol)).to eq nil } # Symbol
        it { expect(subject.coerce('0')).to eq '0' } # String
        it { expect(subject.coerce('3')).to eq '3' }
        it { expect(subject.coerce('-3')).to eq('-3') }
        it { expect(subject.coerce('wibble')).to eq 'wibble' }
        it { expect(subject.coerce(0.0)).to eq nil } # Float
        it { expect(subject.coerce(3.0)).to eq nil }
        it { expect(subject.coerce(-3.0)).to eq(nil) }
      end
    end
    context 'when coercible' do
      let(:coercible) { true }
      context '#coercible?' do
        it { expect(subject.coercible?(nil)).to eq false } # Nil
        it { expect(subject.coercible?(0)).to eq true } # Integer
        it { expect(subject.coercible?(3)).to eq true }
        it { expect(subject.coercible?(-3)).to eq true }
        it { expect(subject.coercible?(:some_symbol)).to eq true } # Symbol
        it { expect(subject.coercible?('0')).to eq true } # String
        it { expect(subject.coercible?('3')).to eq true }
        it { expect(subject.coercible?('-3')).to eq true }
        it { expect(subject.coercible?('wibble')).to eq true }
        it { expect(subject.coercible?(0.0)).to eq true } # Float
        it { expect(subject.coercible?(3.0)).to eq true }
        it { expect(subject.coercible?(-3.0)).to eq true }
        it { expect(subject.coercible?(bd_value)).to eq true } # Decimal
        it { expect(subject.coercible?(date_value)).to eq true } # Date
        it { expect(subject.coercible?(datetime_value)).to eq true } # DateTime
        it { expect(subject.coercible?(time_value)).to eq true } # Time
        it { expect(subject.coercible?(true)).to eq true } # Boolean
        it { expect(subject.coercible?(false)).to eq true }
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq '0' } # Integer
        it { expect(subject.coerce(3)).to eq '3' }
        it { expect(subject.coerce(-3)).to eq('-3') }
        it { expect(subject.coerce(:some_symbol)).to eq 'some_symbol' } # Symbol
        it { expect(subject.coerce('0')).to eq '0' } # String
        it { expect(subject.coerce('3')).to eq '3' }
        it { expect(subject.coerce('-3')).to eq('-3') }
        it { expect(subject.coerce('wibble')).to eq 'wibble' }
        it { expect(subject.coerce(0.0)).to eq '0.0' } # Float
        it { expect(subject.coerce(3.0)).to eq '3.0' }
        it { expect(subject.coerce(-3.0)).to eq('-3.0') }
        it { expect(subject.coerce(bd_value)).to eq '12.34' } # Decimal
        it { expect(subject.coerce(date_value)).to eq '2020-03-01' } # Date
        it { expect(subject.coerce(datetime_value)).to eq '2020-03-01 04:15:25' } # DateTime
        it { expect(subject.coerce(time_value)).to eq '2020-03-01 04:15:25' } # Time
        it { expect(subject.coerce(true)).to eq 'true' } # Boolean
        it { expect(subject.coerce(false)).to eq 'false' }
      end
    end
  end
end
