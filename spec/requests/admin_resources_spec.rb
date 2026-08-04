require "rails_helper"

RSpec.describe "Admin resources", type: :request do
  let(:admin) { create(:admin_user) }

  before { sign_in_admin(admin) }

  describe "AdminUsers" do
    it "indexes, creates, shows, edits, and updates" do
      get admin_admin_users_path
      expect(response).to have_http_status(:ok)

      get new_admin_admin_user_path
      expect(response).to have_http_status(:ok)

      post admin_admin_users_path, params: { admin_user: { name: "Admin 2", email: "admin2@x.com", password: "password123", password_confirmation: "password123", status: "active" } }
      expect(response).to redirect_to(admin_admin_users_path)

      au = AdminUser.last
      get edit_admin_admin_user_path(au)
      expect(response).to have_http_status(:ok)

      patch admin_admin_user_path(au), params: { admin_user: { name: "Renamed" } }
      expect(response).to redirect_to(admin_admin_users_path)
      expect(au.reload.name).to eq("Renamed")
    end

    it "rejects invalid create and update" do
      post admin_admin_users_path, params: { admin_user: { name: "", email: "" } }
      expect(response).to have_http_status(:unprocessable_entity)

      au = create(:admin_user)
      patch admin_admin_user_path(au), params: { admin_user: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Businesses" do
    it "indexes, creates, shows, edits, and updates" do
      get admin_businesses_path
      expect(response).to have_http_status(:ok)

      get new_admin_business_path
      expect(response).to have_http_status(:ok)

      post admin_businesses_path, params: { business: { name: "Biz 2", code: "BIZ2", currency: "PHP", status: "active" } }
      expect(response).to redirect_to(admin_businesses_path)

      biz = Business.last
      get admin_business_path(biz)
      expect(response).to have_http_status(:ok)

      get edit_admin_business_path(biz)
      expect(response).to have_http_status(:ok)

      patch admin_business_path(biz), params: { business: { name: "Biz 2 Renamed" } }
      expect(response).to redirect_to(admin_businesses_path)
      expect(biz.reload.name).to eq("Biz 2 Renamed")
    end

    it "rejects invalid create" do
      post admin_businesses_path, params: { business: { name: "", code: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "admin authorization" do
    it "requires an admin user" do
      delete logout_path
      get admin_businesses_path
      expect(response).to redirect_to(login_path)
    end
  end
end
