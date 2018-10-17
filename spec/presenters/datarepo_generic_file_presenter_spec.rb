require 'spec_helper'

describe DatarepoGenericFilePresenter do
  describe ".terms" do
    it "returns a list" do
      expect(described_class.terms).to match_array([:resource_type, :title,
                                           :creator, :contributor, :description, :tag, :rights,
                                           :date_created, :subject, :language, :based_near,
                                           :related_url, :provenance])
    end
  end

  let(:presenter) { described_class.new(file) }

  describe '#provenance' do
    let(:file) { build(:generic_file, provenance: ["processing history"]) }

    it "displays provenance metadata" do 
      expect(presenter.provenance). to match_array(["processing history"])
    end
  end
end
