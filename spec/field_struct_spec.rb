# frozen_string_literal: true

RSpec.describe FieldStruct do
  it 'has a version number' do
    expect(FieldStruct::VERSION).not_to be nil
  end
  describe 'class definition' do
    context 'on invalid' do
      context 'attribute set' do
        let(:klass) { Class.new(FieldStruct::Value) { attribute :name, :dancing } }
        it('raises error') do
          expect { klass }.to raise_error FieldStruct::TypeError, 'Unknown type [:dancing]'
        end
      end
      context 'attribute option' do
        let(:klass) { Class.new(FieldStruct::Value) { attribute :name, :string, :rocking } }
        it('raises error') do
          expect { klass }.to raise_error FieldStruct::AttributeOptionError, 'Unknown option for attribute [:rocking]'
        end
      end
    end
  end
end
