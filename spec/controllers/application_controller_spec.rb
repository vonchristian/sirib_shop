require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    before_action :require_login

    def index
      render plain: "ok"
    end
  end

  let(:user) { create(:user) }

  describe "auth guards" do
    it "redirects unauthenticated requests to login" do
      routes.draw { get "test" => "anonymous#index" }
      get :index
      expect(response).to redirect_to(login_path)
    end

    it "lets a signed-in user through" do
      routes.draw { get "test" => "anonymous#index" }
      session[:user_id] = user.id
      get :index
      expect(response.body).to eq("ok")
    end
  end
end
