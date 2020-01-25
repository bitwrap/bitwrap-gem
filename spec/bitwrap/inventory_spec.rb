require 'spec_helper'
require 'bitwrap/state_vector'
require 'pipe/jruby'
require 'json'
require 'pp'

describe Bitwrap::StateVector do

  let! :schema_file do
    "#{File.dirname(__FILE__)}/../schemata/inventory.json"
  end

  let! :vector do
    described_class.new(JSON.parse(File.read(schema_file)))
  end

  let :invalid_state do
    [-1]
  end

  let :initial_state do
    [1, 5, 1]
  end

  let :inhibited_initial do
    [0, 5, 1]
  end

  let :acquired_gold do
    [0, 0, 3]
  end
  
  let :decorated_initial do
    {"user_flag"=>1,
     "user_wallet"=>5,
     "system_wallet"=>1}
  end

  let :initial_transitions do
    [{:label=>"spend_cash_acquire_gold", :value=>[-1, -5, 2]},
     {:label=>"spend_gold_acquire_soft", :value=>[-1, 0, 1]}]
  end

  before :all do
    pipe_to_json "#{File.dirname(__FILE__)}/../schemata/inventory"
  end

  it { expect(vector.initial).to eql initial_state }
  it { expect(vector.decorate(initial_state)).to  eql decorated_initial }
  it { expect(vector.valid_transitions(initial_state)).to eql initial_transitions }
  it { expect(vector.valid_transitions(invalid_state)).to eql [] }

  it { expect(vector.transform(initial_state, 'spend_cash_acquire_gold')).to eql acquired_gold }
  it { expect(vector.inhibit(initial_state)).to eql inhibited_initial }

end
