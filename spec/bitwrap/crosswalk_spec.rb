require 'spec_helper'
require 'bitwrap/state_vector'

describe Bitwrap::StateVector do

  let! :schema_file do
    "#{File.dirname(__FILE__)}/../schemata/cross.example.com.json"
  end

  let! :vector do
    @v ||= described_class.new(JSON.parse(File.read(schema_file)))
  end

  let :initial_state do
    [1, 1, 0, 0]
  end

  let :inhibited_initial do
    [0, 1, 0]
  end

  let :cross do
    vector.lookup('cross')
  end

  let :walk do
    vector.lookup('walk')
  end

  before :all do
    pipe_to_json "#{File.dirname(__FILE__)}/../schemata/cross.example.com"
  end

  xit { expect(vector.lookup(vector.lookup('cross'))).to eq(cross) }

  context ".valid?" do
    it { expect(vector.valid?([])).to be false }
  end

  context ".empty?" do
    it { expect(vector.empty?([0, 0, 0])).to be true }
  end

  context ".vadd" do
    it "should add 2 vectors" do
      expect(
        vector.vadd([0, 0, 1 ], [1, 0, -1])
      ).to eq([1, 0, 0])
    end
  end

  context ".inhibit" do
    it { expect(vector.inhibit(initial_state)).to eq(inhibited_initial) }
  end

  context "valid transitions when inhibitor is met" do
    subject { vector.valid_transitions(initial_state) }

    it "not all transitions should be valid" do
      expect(subject.count < vector.transitions.count).to be true
    end

    xit { expect(subject).to include(walk[:value]) }
  end

  context "valid transitions when inhibitor is unmet" do
    subject { vector.valid_transitions(inhibited_initial) }

    xit "not all transitions should be valid" do
      expect(subject.count < vector.transition_vectors.count).to be true
    end

    it { expect(subject).not_to include(walk) }
  end

end
