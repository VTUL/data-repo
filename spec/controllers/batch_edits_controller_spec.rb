require 'spec_helper'

describe BatchEditsController, type: :controller do
  before do
    sign_in FactoryGirl.create(:default_user)
    allow_any_instance_of(User).to receive(:groups).and_return([])
    request.env["HTTP_REFERER"] = 'test.host/original_page'
  end

  describe "edit" do
    before do
      @one = GenericFile.new(creator: ["Fred"], description: ['foo'])
      @one.apply_depositor_metadata('mjg36')
      @two = GenericFile.new(creator: ["Wilma"], description: ['foo'])
      @two.apply_depositor_metadata('mjg36')
      @one.save!
      @two.save!
      controller.batch = [@one.id, @two.id]
      expect(controller).to receive(:can?).with(:edit, @one.id).and_return(true)
      expect(controller).to receive(:can?).with(:edit, @two.id).and_return(true)
    end

    it "is successful" do
      get :edit
      expect(response).to be_successful
      # only allow publisher, provenance, identifier edits if admin
      expect(assigns[:terms]).to eq [:creator, :contributor, :description, :tag, :rights, :date_created, 
                                     :subject, :language, :based_near, :related_url]
      expect(assigns[:generic_file]).to have_attributes("creator": ["Fred", "Wilma"], "description": ["foo"])
    end
  end

  describe "update" do
    let!(:one) do
      GenericFile.create(creator: ["Fred"], description: ['foo']) do |file|
        file.apply_depositor_metadata('mjg36')
      end
    end

    let!(:two) do
      GenericFile.create(creator: ["Fred"], description: ['foo']) do |file|
        file.apply_depositor_metadata('mjg36')
      end
    end

    before do
      controller.batch = [one.id, two.id]
      expect(controller).to receive(:can?).with(:edit, one.id).and_return(true)
      expect(controller).to receive(:can?).with(:edit, two.id).and_return(true)
    end

    let(:mycontroller) { "my/files" }

    it "updates the records" do
      put :update, update_type: "update", generic_file: { creator: ["zzz"] }
      expect(response).to be_redirect
      expect(GenericFile.find(one.id).creator).to eq ["zzz"]
      expect(GenericFile.find(two.id).creator).to eq ["zzz"]
    end
  end
end

