require 'rspec'
require "capybara"
require "spec_helper"

# save_and_open_page

def create_user
  visit "/"
  click_button "Register"
  fill_in_registration("Alex","alexmcray")
  click_button "submit_button"
end

def login
  visit "/"
  fill_in "username", :with => "alexmcray"
  fill_in "password", :with => "123"
  click_button "Login"
end

def fill_in_registration(first_name, username)
  fill_in "first_name", :with => first_name
  fill_in "last_name", :with => "Mc"+first_name
  fill_in "email", :with => first_name+"@gmail.com"
  fill_in "username", :with => username
  fill_in "password", :with => "123"
  fill_in "confirm_password", :with => "123"
end

feature "New user." do
  def test_field(field, feedback, answer)
    fill_in field, :with => ""
    click_button "Register"
    expect(page).to have_content(feedback)
    fill_in field, :with => answer
  end

  scenario "Visit home page." do
    visit "/"
    click_button "Register"
    expect(page).to have_content("Register for Cyvasse")
  end
  scenario "Blank user info." do
    visit "/"
    click_button "Register"
    test_field("first_name", "Please fill in your first name.", "Alex")
    test_field("last_name", "Please fill in your last name.", "McRitchie")
    test_field("email", "Please fill in your email.", "alexmcray@aol.com")
    test_field("username", "Please fill in a username.", "alexmcray")
    test_field("password", "Please create a password.", "123")
    test_field("confirm_password", "Please enter your password identically", "123")
    fill_in "password", :with => "123"
    click_button "submit_button"
    expect(page).to have_content("Welcome Alex, thanks registering!")
  end
  scenario "Register User." do
    create_user
    expect(page).to have_content("Welcome Alex, thanks registering!")
  end
  scenario "Duplicate of username." do
    create_user
    create_user
    expect(page).to have_content("Username is already in use, please choose another.")
  end
end

feature "Login and out." do
  before(:each) do
    create_user
  end
  scenario "User welcome." do
    visit "/"
    fill_in "username", :with => "alexmcray"
    fill_in "password", :with => "123"
    click_button "Login"
    expect(page).to have_content("Welcome, Alex")
  end
  scenario "Blank or incorrect username" do
    visit "/"
    fill_in "username", :with => ""
    fill_in "password", :with => "123"
    click_button "Login"
    expect(page).to have_content("I'm sorry, but we couldn't find that username.")
  end
  scenario "Blank or incorrect password" do
    visit "/"
    fill_in "username", :with => "alexmcray"
    fill_in "password", :with => ""
    click_button "Login"
    expect(page).to have_content("I'm sorry, but that password does not match that username.")
  end
  scenario "logout" do

    visit "/"
    fill_in "username", :with => "alexmcray"
    fill_in "password", :with => "123"
    click_button "Login"
    click_button "Logout"
    expect(page).to have_button("Register")
  end

end

feature "Start a game." do
  before(:each) do
    create_user
    login
    click_button "Start a game of Cyvasse"
  end

end
