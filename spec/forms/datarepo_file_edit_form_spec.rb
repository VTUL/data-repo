require 'spec_helper'

describe DatarepoFileEditForm do
  subject { described_class.new(GenericFile.new) }

  describe "#terms" do
    it "returns a list" do
      expect(subject.terms).to eq([:resource_type, :title, :creator, :contributor, :description, :tag, :rights,
                                   :date_created, :subject, :language, :based_near, :related_url])
    end
  end

  it "initializes provenance field" do
    expect(subject.provenance).to eq []
  end

  describe ".model_attributes" do
    let(:params) { ActionController::Parameters.new(provenance: ['foo'], description: [''], "permissions_attributes" => { "2" => { "access" => "edit", "_destroy" => "true", "id" => "a987551e-b87f-427a-8721-3e5942273125" } }) }
    subject { described_class.model_attributes(params) }

    it "only changes provenance" do
      expect(subject['provenance']).to be_nil
      expect(subject['description']).to be_empty
      expect(subject['permissions_attributes']).to eq("2" => { "access" => "edit", "id" => "a987551e-b87f-427a-8721-3e5942273125", "_destroy" => "true" })
    end
  end
end
