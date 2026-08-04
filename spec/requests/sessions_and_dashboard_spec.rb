require "rails_helper"

RSpec.describe "Sessions & dashboard", type: :request do
  describe "Sessions" do
    it "renders the login form" do
      get login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign in")
    end

    it "rejects an unknown user" do
      post login_path, params: { email: "nobody@example.com", password: "wrong" }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "signs out and redirects to login" do
      user = create(:user)
      post login_path, params: { email: user.email, password: "password123" }
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "Dashboard" do
    it "redirects to login when not authenticated" do
      get root_path
      expect(response).to redirect_to(login_path)
    end

    it "renders the dashboard when signed in" do
      sign_in(create(:user))
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
