require "sinatra"
require "gschool_database_connection"
require "active_record"
require "rack-flash"
require_relative "lib/users_table"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @users_table = UsersTable.new(
        GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    )
  end

  def field_check(field, feedback, key)
    if field != ''
      @register_attempt.merge!(key => field)
    else
      @register_attempt[:continue] = false
      flash[:registration] = feedback
      # return @register_attempt
    end
    @register_attempt
  end

  def check_fields(new_user)
    @register_attempt = {:continue => true}

    field_check(new_user[:first], "Please fill in your first name.", :first_name)
    if !@register_attempt[:continue]
      return @register_attempt
    end

    field_check(new_user[:last], "Please fill in your last name.", :last_name)
    if !@register_attempt[:continue]
      return @register_attempt
    end

    field_check(new_user[:email], "Please fill in your email.", :email)
    if !@register_attempt[:continue]
      return @register_attempt
    end

    if new_user[:username] == ''
      flash[:registration] = "Please fill in a username."
      return @register_attempt
    elsif @users_table.find_user(new_user[:username]) != []
      flash[:registration] = "Username is already in use, please choose another."
      return @register_attempt
    end
    @register_attempt.merge!(:username => new_user[:username])

    if new_user[:password] == ''
      flash[:registration] = "Please create a password."
      return @register_attempt
    end
    @register_attempt.merge!(:password => new_user[:password])

  end

  get "/" do
    users = @users_table.users

    erb :root, :locals => {:users => users}
  end

  get "/registration" do
    register_attempt = {}
    erb :registration, :locals => {:register_attempt => register_attempt}
  end

  get "/about_cyvasse" do
    users = @users_table.users
    erb :about_cyvasse
  end

  post "/registration" do

    new_user = {
        :first => params[:first_name],
        :last => params[:last_name],
        :email => params[:email],
        :username => params[:username],
        :password => params[:password],
        :confirm_password => params[:confirm_password]}

    register_attempt = check_fields(new_user.each {|k,v| v.downcase!})

    if register_attempt.count < (new_user.count)
      erb :registration, :locals => {:register_attempt => register_attempt}
    elsif params[:password] != params[:confirm_password]
      flash[:registration] = "Please enter your password identically"
      erb :registration, :locals => {:register_attempt => register_attempt}
    else
      flash[:notice] = "Welcome #{params[:first_name].capitalize}, thanks registering!"
      flash[:registration] = nil
      @users_table.create(params[:first_name], params[:last_name], params[:email], params[:username], params[:password])
      redirect "/"
    end
  end

  post "/login" do
    user = @users_table.find_username(params[:username])
    if user == nil
      flash[:login_fail] = "I'm sorry, but we couldn't find that username."
      redirect "/"
    elsif user["password"] != params[:password]
      flash[:login_fail] = "I'm sorry, but that password does not match that username."
      redirect "/"
    end
    session[:user_id] = user["id"]
    flash[:not_logged_in] = true
    flash[:login] = "Welcome, #{user["first_name"].capitalize}"
    redirect "/"
  end

  post "/logout" do
    session[:user_id] = nil
    redirect "/"
  end
end

