require 'spec_helper'

describe "AuthenticationPages" do

  subject { page }

  describe "Signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }

    describe "Invalid login" do
      before { click_button "Sign in" }

      it { should have_selector('title', text: 'Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }
    end

    describe "Valid login" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_selector('title', text: user.name) }
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should_not have_link('Sign in', href: signin_path) }
    end

    describe "after visiting another page" do
      before { click_link "Home" }
      it { should_not have_selector('div.alert.alert-error') }
    end
  end

  describe "Authorization" do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:admin) }

    describe "For non signed-in user" do

      describe "in user controller" do

        describe "Visiting edit user path" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: "Sign in")}
        end

        describe "Submit to update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "Submit delete to destroy action" do
          before { delete user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
      end

      describe "visiting a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        it { should have_selector('title', text: 'Edit user') }

      end
    end

    describe "For wrong user" do
      let(:wrong_user) { FactoryGirl.create(:user, email: 'new_email@newhost.com') }

      before { sign_in wrong_user }

      describe "in user controller" do

        describe "Visiting edit user path" do
          before { visit edit_user_path(user) }
          it { should_not have_selector('title', text: full_title('Edit user')) }
        end

        describe "Submit to update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(root_path) }
        end
      end
    end

    describe "For non-admin user" do
      before { sign_in user }

      describe "submit delete to destroy path" do
        before { delete user_path(user) }

        specify { response.should redirect_to(root_path) }
      end
    end

    describe "For admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      let(:admin2) { FactoryGirl.create(:admin, email: 'newemail@example.com') }

      before { sign_in admin }

      describe "won't be able to delete other admin" do
        before { delete user_path(admin2) }
        specify { response.should redirect_to(root_path) }
      end

      describe "won't be able to delete himself" do
        before { delete user_path(admin)}
        specify { response.should redirect_to(root_path) }
      end
    end
  end
end
