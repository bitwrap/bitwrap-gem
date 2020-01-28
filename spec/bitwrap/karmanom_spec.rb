require 'spec_helper'
require 'bitwrap/state_vector'
require 'json'
require 'pp'

describe Bitwrap::StateVector do

  let! :schema_file do
    "#{File.dirname(__FILE__)}/../schemata/karmanom.com.json"
  end

  let! :vector do
    described_class.new(JSON.parse(File.read(schema_file)))
  end

  let :invalid_state do
    [-1]
  end

  let :initial_state do
    [1, 1, 1, 1, 1, 1, 1, 1, 1]
  end

  let :inhibited_initial do
    [0, 0, 1, 1, 0, 1, 1, 1, 1]
  end

  let :recall do
    [-1, 0, 0, -1, 0, 1, -1, -1, 0]
  end

  let :recalled do
    [0, 1, 1, 0, 1, 2, 0, 0, 1]
  end
  
  let :decorated_initial do
    { "subject_flag"   => 1,
      "user_flag"      => 1,
      "positive_tally" => 1,
      "negative_tally" => 1,
      "system_flag"    => 1,
      "user_wallet"    => 1,
      "recall_tally"   => 1,
      "subject_wallet" => 1,
      "system_wallet"  => 1 }
  end

  let :initial_transitions do
    [{:label=>"negative_tip",       :value=>[0, -1, 0, 1, 0, -1, 0, 1, 0]},
     {:label=>"positive_donate",    :value=>[0, -1, 1, 0, 0, -1, 0, 0, 1]},
     {:label=>"negative_donate",    :value=>[0, -1, 0, 1, 0, -1, 0, 0, 1]},
     {:label=>"deposit",            :value=>[0, -1, 0, 0, -1, 1, 0, 0, 0]},
     {:label=>"deposit_donation",   :value=>[0, 0, 0, 0, -1, 0, 0, 0, -1]},
     {:label=>"refund",             :value=>[-1, 0, 0, 0, 0, 1, -1, -1, 0]},
     {:label=>"recall",             :value=>[-1, 0, 0, -1, 0, 1, -1, -1, 0]},
     {:label=>"vote",               :value=>[0, -1, 0, 0, 0, -1, 1, 0, 1]},
     {:label=>"withdraw",           :value=>[0, -1, 0, 0, -1, -1, 0, 0, 0]},
     {:label=>"tip_user",           :value=>[-1, 0, 0, 0, 0, 1, 0, -1, 0]},
     {:label=>"positive_tip",       :value=>[0, -1, 1, 0, 0, -1, 0, 1, 0]}]
  end

  before :all do
    pipe_to_json "#{File.dirname(__FILE__)}/../schemata/karmanom.com"
  end

  it { expect(vector.initial).to eql initial_state }
  it { expect(vector.lookup('recall')[:value]).to eql recall }
  it { expect(vector.decorate(initial_state)).to  eql decorated_initial }
  it { expect(vector.valid_transitions(initial_state)).to eql initial_transitions }
  it { expect(vector.valid_transitions(invalid_state)).to eql [] }
  it { expect(vector.transform(initial_state, 'recall')).to eql recalled }
  it { expect(vector.inhibit(initial_state)).to eql inhibited_initial }

end
