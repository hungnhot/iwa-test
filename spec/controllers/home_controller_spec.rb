require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    let(:params) {
      {
        page: 1
      }
    }

    it "returns http success" do
      get :index, params: params
      expect(response).to have_http_status(:success)
      expect(assigns(:data).count).to be > 0
      expect(assigns(:page)).to eq(1)
    end
  end

  describe "GET #article" do
    let(:params) {
      {
        url: "https://overreacted.io/goodbye-clean-code/"
      }
    }

    it "returns http success" do
      get :article, params: params
      expect(response).to have_http_status(:success)
      expect(assigns(:data)).to be_present
    end
  end

end
