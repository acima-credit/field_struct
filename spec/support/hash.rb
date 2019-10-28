# frozen_string_literal: true

module HashHelpers
  def basic_hash(hsh = ::HashWithIndifferentAccess.new)
    return hsh if hsh.is_a?(::HashWithIndifferentAccess)

    ::HashWithIndifferentAccess.new hsh
  end

  def expect_same_hash(expected, actual)
    exp = basic_hash expected
    act = basic_hash actual
    dif = Hashdiff.diff act, exp

    if ENV.fetch('DEBUG', 'false') == 'true'
      puts "<<< act >>>\n #{act.inspect}"
      puts "<<< exp >>>\n #{exp.inspect}"
      puts "<<< dif >>>\n #{dif.inspect}"
    end

    expect(act).to include_json exp
    expect(dif).to eq([])
  end

  def expect_included_hash(expected, actual)
    exp = basic_hash expected
    act = basic_hash actual
    expect(act).to include_json exp
    # expect(act).to eq exp
  end
end

RSpec.configure do |config|
  config.include HashHelpers
end
