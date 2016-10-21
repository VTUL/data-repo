require 'spec_helper'

describe HomepageController, type: :controller do
  context 'with existing featured work' do
    let!(:feat_work) { ContentBlock.create!(name: ContentBlock::WORK, value: 'Interesting Work') }

    it 'shows the featured work' do
      get :index
      expect(response).to be_success
      expect(assigns(:featured_work)).to eq feat_work
    end
  end

  context 'without a featured work' do
    it 'sets the featured work' do
      get :index
      expect(response).to be_success
      assigns(:featured_work).tap do |work|
        expect(work).to be_kind_of ContentBlock
        expect(work.name).to eq 'featured_work'
      end
    end
  end
end
