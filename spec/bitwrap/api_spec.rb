require 'spec_helper'
require 'bitwrap/state_vector'
require 'json'
require 'pp'

describe Bitwrap::StateVector do

  let! :schema_file do
    "#{File.dirname(__FILE__)}/../schemata/api.bitwrap.io.json"
  end

  let! :vector do
    described_class.new(JSON.parse(File.read(schema_file)))
  end

  let :invalid_state do
    [-1]
  end

  let :initial_state do
    [1, 1, 1]
  end

  let :inhibited_initial do
    [0, 0, 1]
  end

  let :created do
    [0, 0, 0]
  end
  
  let :decorated_initial do
    {"system_flag" => 1,
     "user_flag"   => 1,
     "user_wallet" => 1}
  end

  let :initial_transitions do
    [{:label=>"POST",  :value=>[-1,  0,  0]},
    {:label=>"GET",    :value=>[-1,  0,  0]},
    {:label=>"create", :value=>[-1, -1, -1]},
    {:label=>"PUT",    :value=>[-1,  0,  0]}]
  end

  before :all do
    pipe_to_json "#{File.dirname(__FILE__)}/../schemata/api.bitwrap.io"
  end

  it { expect(vector.initial).to eql initial_state }
  it { expect(vector.decorate(initial_state)).to  eql decorated_initial }
  it { expect(vector.valid_transitions(initial_state)).to eql initial_transitions }
  it { expect(vector.valid_transitions(invalid_state)).to eql [] }

  it { expect(vector.transform(initial_state, 'create')).to eql created }
  it { expect(vector.inhibit(initial_state)).to eql inhibited_initial }

end
