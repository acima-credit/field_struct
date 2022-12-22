# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldedStruct::Types::Boolean, type: :type do
  describe 'class' do
    it { expect(described_class.ancestors).to include FieldedStruct::Types::Base }
    it { expect(described_class.type).to eq :boolean }
    it { expect(described_class.base_type).to eq [TrueClass, FalseClass] }
  end
  # rubocop:disable Lint/BooleanSymbol
  describe 'instance' do
    subject { described_class.new attribute }
    let(:attribute_type) { :boolean }
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
        it { expect(subject.coercible?(true)).to eq true } # Boolean
        it { expect(subject.coercible?(false)).to eq true }
        it { expect(subject.coercible?(bd_value)).to eq false } # Decimal
        it { expect(subject.coercible?(date_value)).to eq false } # Date
        it { expect(subject.coercible?(datetime_value)).to eq false } # DateTime
        it { expect(subject.coercible?(time_value)).to eq false } # Time
        it { expect(subject.coercible?(true)).to eq true } # Boolean
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq nil } # Integer
        it { expect(subject.coerce(3)).to eq nil }
        it { expect(subject.coerce(-3)).to eq nil }
        it { expect(subject.coerce(:some_symbol)).to eq nil } # Symbol
        it { expect(subject.coerce(:'0')).to eq nil }
        it { expect(subject.coerce(:'1')).to eq nil }
        it { expect(subject.coerce(:true)).to eq nil }
        it { expect(subject.coerce(:false)).to eq nil }
        it { expect(subject.coerce(:on)).to eq nil }
        it { expect(subject.coerce(:off)).to eq nil }
        it { expect(subject.coerce('0')).to eq nil } # String
        it { expect(subject.coerce('3')).to eq nil }
        it { expect(subject.coerce('-3')).to eq nil }
        it { expect(subject.coerce('f')).to eq nil }
        it { expect(subject.coerce('F')).to eq nil }
        it { expect(subject.coerce('false')).to eq nil }
        it { expect(subject.coerce('FALSE')).to eq nil }
        it { expect(subject.coerce('False')).to eq nil }
        it { expect(subject.coerce('off')).to eq nil }
        it { expect(subject.coerce('Off')).to eq nil }
        it { expect(subject.coerce('true')).to eq nil }
        it { expect(subject.coerce('True')).to eq nil }
        it { expect(subject.coerce('TRUE')).to eq nil }
        it { expect(subject.coerce('On')).to eq nil }
        it { expect(subject.coerce('wibble')).to eq nil }
        it { expect(subject.coerce(0.0)).to eq nil } # Float
        it { expect(subject.coerce(3.0)).to eq nil }
        it { expect(subject.coerce(-3.0)).to eq nil }
        it { expect(subject.coerce(true)).to eq true } # Boolean
        it { expect(subject.coerce(false)).to eq false }
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
        it { expect(subject.coercible?(0.0)).to eq false } # Float
        it { expect(subject.coercible?(3.0)).to eq false }
        it { expect(subject.coercible?(-3.0)).to eq false }
        it { expect(subject.coercible?(bd_value)).to eq false } # Decimal
        it { expect(subject.coercible?(date_value)).to eq false } # Date
        it { expect(subject.coercible?(datetime_value)).to eq false } # DateTime
        it { expect(subject.coercible?(time_value)).to eq false } # Time
        it { expect(subject.coercible?(true)).to eq true } # Boolean
        it { expect(subject.coercible?(false)).to eq true }
      end
      context '#coerce' do
        it { expect(subject.coerce(nil)).to eq nil } # Nil
        it { expect(subject.coerce(0)).to eq false } # Integer
        it { expect(subject.coerce(3)).to eq true }
        it { expect(subject.coerce(-3)).to eq true }
        it { expect(subject.coerce(:some_symbol)).to eq true } # Symbol
        it { expect(subject.coerce(:'0')).to eq false }
        it { expect(subject.coerce(:'1')).to eq true }
        it { expect(subject.coerce(:true)).to eq true }
        it { expect(subject.coerce(:false)).to eq false }
        it { expect(subject.coerce(:on)).to eq true }
        it { expect(subject.coerce(:off)).to eq false }
        it { expect(subject.coerce('0')).to eq false } # String
        it { expect(subject.coerce('3')).to eq true }
        it { expect(subject.coerce('-3')).to eq true }
        it { expect(subject.coerce('f')).to eq false }
        it { expect(subject.coerce('F')).to eq false }
        it { expect(subject.coerce('false')).to eq false }
        it { expect(subject.coerce('FALSE')).to eq false }
        it { expect(subject.coerce('False')).to eq false }
        it { expect(subject.coerce('off')).to eq false }
        it { expect(subject.coerce('Off')).to eq false }
        it { expect(subject.coerce('true')).to eq true }
        it { expect(subject.coerce('True')).to eq true }
        it { expect(subject.coerce('TRUE')).to eq true }
        it { expect(subject.coerce('On')).to eq true }
        it { expect(subject.coerce('wibble')).to eq true }
        it { expect(subject.coerce(0.0)).to eq nil } # Float
        it { expect(subject.coerce(3.0)).to eq nil }
        it { expect(subject.coerce(-3.0)).to eq nil }
        it { expect(subject.coerce(bd_value)).to eq nil } # Decimal
        it { expect(subject.coerce(date_value)).to eq nil } # Date
        it { expect(subject.coerce(datetime_value)).to eq nil } # DateTime
        it { expect(subject.coerce(time_value)).to eq nil } # Time
        it { expect(subject.coerce(true)).to eq true } # Boolean
        it { expect(subject.coerce(false)).to eq false }
      end
    end
  end
  # rubocop:enable Lint/BooleanSymbol
end
