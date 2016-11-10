require 'spec_helper'

describe GenericFilesController, type: :controller do
  routes { Sufia::Engine.routes }
  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in user
  end

  describe "PUT #update" do
    let(:generic_file) do
      GenericFile.create do |gf|
        gf.apply_depositor_metadata(user)
        gf.title = ['test title']
      end
    end

    context "with valid metadata" do
      before(:example) do
        put :update, id: generic_file, generic_file: { title: ['new_title']}
        generic_file.reload
      end

      it "changes file's metadata" do
        expect(generic_file.title).to match_array(['new_title'])
      end

      it "redirects to the show page" do
        expect(response).to redirect_to routes.url_helpers.generic_file_path(generic_file)
        expect(response).not_to redirect_to routes.url_helpers.edit_generic_file_path(generic_file)
        expect(flash[:notice]).to include 'File was successfully updated.'
      end
    end

    context "with invalid metadata" do
      before(:example) do
        generic_file.reload
      end

      it "redirects to edit" do
        expect_any_instance_of(GenericFile).to receive(:valid?).and_return(false)
        put :update, id: generic_file, generic_file: { title: ['new_title'], tag: [''] }
        generic_file.reload
        expect(response).to be_successful
        expect(response).to render_template("edit")
        expect(response).not_to redirect_to routes.url_helpers.generic_file_path(generic_file)
        expect(assigns[:generic_file]).to eq generic_file
        expect(generic_file.title).to match_array(['test title'])
        expect(flash[:error]).to include 'Update was unsuccessful.'
      end
    end
  end
end

