require 'spec_helper'

describe GenericFile, :type => :model do
  
  describe ".properties" do
    subject { described_class.properties.keys }
    it { is_expected.to include("provenance") }
  end

  describe "#dc metadata" do
    it "allows reading and writing for dc provenance" do
      subject.provenance = ['foo', 'bar']
      expect(subject.provenance).to match_array(['foo', 'bar'])
    end
  end

  describe "metadata" do
    it "has descriptive metadata" do
      expect(subject).to respond_to(:resource_type)
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:contributor)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:tag)
      expect(subject).to respond_to(:rights)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:subject)
      expect(subject).to respond_to(:language)
      expect(subject).to respond_to(:identifier)
      expect(subject).to respond_to(:based_near)
      expect(subject).to respond_to(:related_url)
      expect(subject).to respond_to(:provenance)
    end
  end
end
