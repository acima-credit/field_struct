# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module Examples
    class UserMutable < FieldStruct.mutable
      attribute :username, :string, format: /^[a-z]/i
      attribute :password, :string, :optional
      attribute :age, :integer
      attribute :owed, :float, :coercible
      attribute :source, :string, :coercible, enum: %w[A B C]
      attribute :level, :integer, default: -> { 2 }
      attribute :at, :time, :coercible, :optional
    end
  end
end

RSpec.describe FieldStruct::Examples::UserMutable do
  let(:str) { "#<#{described_class.name} #{fields_str}>" }

  let(:username) { 'johnny' }
  let(:password) { 'p0ssw3rd' }
  let(:age) { 3 }
  let(:owed) { 20.75 }
  let(:source) { 'A' }
  let(:level) { 3 }
  let(:at) { nil }
  let(:params) do
    {
      username: username,
      password: password,
      age:      age,
      owed:     owed,
      source:   source,
      level:    level,
      at:       at
    }
  end
  subject { described_class.new params }

  context 'class' do
    let(:attr_names) { %i[username password age owed source level at] }
    it('attribute_names') { expect(described_class.attribute_names).to eq attr_names }
  end

  context 'basic' do
    let(:fields_str) do
      'username="johnny" password="p0ssw3rd" age=3 owed=20.75 source="A" level=3 at=nil'
    end
    let(:values) { [username, password, age, owed, source, level, at] }
    it('to_s      ') { expect(subject.to_s).to eq str }
    it('inspect   ') { expect(subject.inspect).to eq str }
    it('username  ') { expect(subject.username).to eq username }
    it('password  ') { expect(subject.password).to eq password }
    it('age       ') { expect(subject.age).to eq age }
    it('owed      ') { expect(subject.owed).to eq owed }
    it('source    ') { expect(subject.source).to eq source }
    it('level     ') { expect(subject.level).to eq level }
    it('at        ') { expect(subject.at).to eq at }
    it('values    ') { expect(subject.values).to eq values }
  end

  context 'with' do
    let(:error_class) { FieldStruct::BuildError }
    context 'username' do
      context 'missing' do
        let(:params) { { password: password, age: age, owed: owed, source: source } }
        it('is ok   ') { expect(subject.username).to eq nil }
        it('is error') { expect(subject.errors).to eq [':username is required'] }
      end
      context 'empty' do
        let(:username) { '' }
        it('is ok   ') { expect(subject.username).to eq '' }
        it('is error') { expect(subject.errors).to eq [':username is required'] }
      end
      context 'nil' do
        let(:username) { nil }
        it('is ok   ') { expect(subject.username).to eq nil }
        it('is error') { expect(subject.errors).to eq [':username is required'] }
      end
    end
    context 'password' do
      context 'missing' do
        let(:params) { { username: username, age: age, owed: owed, source: source } }
        it('is ok') { expect(subject.password).to be_nil }
      end
      context 'empty' do
        let(:password) { '' }
        it('is ok') { expect(subject.password).to eq '' }
      end
      context 'nil' do
        let(:password) { nil }
        it('is ok') { expect(subject.password).to be_nil }
      end
    end
    context 'age' do
      context 'missing' do
        let(:params) { { username: username, password: password, owed: owed, source: source } }
        it('is ok   ') { expect(subject.age).to eq nil }
        it('is error') { expect(subject.errors).to eq [':age is required'] }
      end
      context 'empty' do
        let(:age) { '' }
        it('is ok   ') { expect(subject.age).to eq '' }
        it('is error') { expect(subject.errors).to eq [':age is required'] }
      end
      context 'nil' do
        let(:age) { nil }
        it('is ok   ') { expect(subject.age).to eq nil }
        it('is error') { expect(subject.errors).to eq [':age is required'] }
      end
    end
    context 'owed' do
      context 'missing' do
        let(:params) { { username: username, password: password, age: age, source: source } }
        it('is ok   ') { expect(subject.owed).to eq nil }
        it('is error') { expect(subject.errors).to eq [':owed is required'] }
      end
      context 'empty' do
        let(:owed) { '' }
        it('is ok   ') { expect(subject.owed).to eq nil }
        it('is error') { expect(subject.errors).to eq [':owed is required'] }
      end
      context 'nil' do
        let(:owed) { nil }
        it('is ok   ') { expect(subject.owed).to eq nil }
        it('is error') { expect(subject.errors).to eq [':owed is required'] }
      end
      context 'invalid' do
        let(:owed) { '$3.o1' }
        it('is ok   ') { expect(subject.owed).to eq nil }
        it('is error') { expect(subject.errors).to eq [':owed is required'] }
      end
      context '0.0' do
        context 'as string' do
          let(:owed) { '0.0' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as float' do
          let(:owed) { 0.0 }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as integer' do
          let(:owed) { 0 }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as decimal' do
          let(:owed) { BigDecimal '0' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
      end
      context '12.34' do
        context 'as string' do
          let(:owed) { '12.34' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=12.34 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as float' do
          let(:owed) { 12.34 }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=12.34 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as decimal' do
          let(:owed) { BigDecimal '12.34' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=12.34 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
      end
      context '-12.34' do
        context 'as string' do
          let(:owed) { '-12.34' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=-12.34 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as float' do
          let(:owed) { -12.34 }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=-12.34 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
        context 'as decimal' do
          let(:owed) { BigDecimal '-12.34' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=-12.34 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.to_f }
        end
      end
      context '$12,345.67' do
        context 'as string' do
          let(:owed) { '$12,345.67' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=12345.67 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.gsub(/\$|\,/, '').to_f }
        end
      end
      context '$-12,345.67' do
        context 'as string' do
          let(:owed) { '$-12,345.67' }
          let(:fields_str) { 'username="johnny" password="p0ssw3rd" age=3 owed=-12345.67 source="A" level=3 at=nil' }
          it('to_s      ') { expect(subject.to_s).to eq str }
          it('owed    ') { expect(subject.owed).to eq owed.gsub(/\$|\,/, '').to_f }
        end
      end
    end
    context 'source' do
      context 'missing' do
        let(:params) { { username: username, password: password, age: age, owed: owed } }
        it('is ok   ') { expect(subject.source).to eq nil }
        it('is error') { expect(subject.errors).to eq [':source is required'] }
      end
      context 'empty' do
        let(:source) { '' }
        it('is ok   ') { expect(subject.source).to eq '' }
        it('is error') { expect(subject.errors).to eq [':source is required'] }
      end
      context 'nil' do
        let(:source) { nil }
        it('is ok   ') { expect(subject.source).to eq nil }
        it('is error') { expect(subject.errors).to eq [':source is required'] }
      end
      context 'unknown' do
        let(:source) { 'unknown' }
        it('is ok   ') { expect(subject.source).to eq 'unknown' }
        it('is error') { expect(subject.errors).to eq [':source is not included in list'] }
      end
      context 'wrong case' do
        let(:source) { 'a' }
        it('is ok   ') { expect(subject.source).to eq 'a' }
        it('is error') { expect(subject.errors).to eq [':source is not included in list'] }
      end
    end
    context 'level' do
      context 'missing' do
        let(:params) { { username: username, password: password, age: age, owed: owed, source: source } }
        it('uses the default') { expect(subject.level).to eq 2 }
      end
      context 'empty' do
        let(:level) { '' }
        it('uses the default') { expect(subject.level).to eq '' }
      end
      context 'nil' do
        let(:level) { nil }
        it('uses the default') { expect(subject.level).to eq nil }
      end
    end
    context 'at' do
      context 'missing' do
        let(:params) { { username: username, password: password, age: age, owed: owed, source: source } }
        it('uses the default') { expect(subject.at).to eq nil }
      end
      context 'empty' do
        let(:at) { '' }
        it('uses the default') { expect(subject.at).to eq '' }
      end
      context 'nil' do
        let(:at) { nil }
        it('uses the default') { expect(subject.at).to eq nil }
      end
    end
  end

  context 'mutability' do
    context 'username' do
      it('responds_to') { expect(subject.respond_to?(:username=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { 'other' }
        it 'changes value' do
          expect { subject.username = new_value }.to_not raise_error
          expect(subject.username).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
      context 'changes invalid value' do
        let(:new_value) { nil }
        it 'changes value' do
          expect { subject.username = new_value }.to_not raise_error
          expect(subject.username).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq false
          expect(subject.errors).to eq [':username is required']
        end
      end
    end
    context 'password' do
      it('responds_to') { expect(subject.respond_to?(:password=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { 'other' }
        it 'changes value' do
          expect { subject.password = new_value }.to_not raise_error
          expect(subject.password).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
    end
    context 'age' do
      it('responds_to') { expect(subject.respond_to?(:age=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { 45 }
        it 'changes value' do
          expect { subject.age = new_value }.to_not raise_error
          expect(subject.age).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
      context 'changes invalid value' do
        let(:new_value) { nil }
        it 'changes value' do
          expect { subject.age = new_value }.to_not raise_error
          expect(subject.age).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq false
          expect(subject.errors).to eq [':age is required']
        end
      end
    end
    context 'owed' do
      it('responds_to') { expect(subject.respond_to?(:owed=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { 2.34 }
        it 'changes value' do
          expect { subject.owed = new_value }.to_not raise_error
          expect(subject.owed).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
      context 'changes invalid value' do
        let(:new_value) { 'wrong owed' }
        it 'changes value' do
          expect { subject.owed = new_value }.to_not raise_error
          expect(subject.owed).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq false
          expect(subject.errors).to eq [':owed is required']
        end
      end
    end
    context 'source' do
      it('responds_to') { expect(subject.respond_to?(:source=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { 'B' }
        it 'changes value' do
          expect { subject.source = new_value }.to_not raise_error
          expect(subject.source).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
      context 'changes invalid value' do
        let(:new_value) { 'F' }
        it 'changes value' do
          expect { subject.source = new_value }.to_not raise_error
          expect(subject.source).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq false
          expect(subject.errors).to eq [':source is not included in list']
        end
      end
    end
    context 'level' do
      it('responds_to') { expect(subject.respond_to?(:level=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { 11 }
        it 'changes value' do
          expect { subject.level = new_value }.to_not raise_error
          expect(subject.level).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
    end
    context 'at' do
      it('responds_to') { expect(subject.respond_to?(:at=)).to eq true }
      context 'changes valid value' do
        let(:new_value) { Time.now }
        it 'changes value' do
          expect { subject.at = new_value }.to_not raise_error
          expect(subject.at).to eq new_value
          expect(subject.errors).to eq([])
          expect(subject.valid?).to eq true
          expect(subject.errors).to eq([])
        end
      end
      context 'changes invalid value' do
        let(:new_value) { 123 }
        context 'with custom writer' do
          it 'changes value' do
            expect { subject.at = new_value }.to_not raise_error
            expect(subject.at).to eq new_value
            expect(subject.errors).to eq([])
            expect(subject.valid?).to eq false
            expect(subject.errors).to eq([':at is invalid'])
          end
        end
        context 'with generic writer' do
          it 'changes value' do
            expect { subject.set :at, new_value }.to_not raise_error
            expect(subject.at).to eq new_value
            expect(subject.errors).to eq([])
            expect(subject.valid?).to eq false
            expect(subject.errors).to eq([':at is invalid'])
          end
        end
      end
    end
  end
end
