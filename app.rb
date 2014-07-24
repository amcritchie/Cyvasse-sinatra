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

  def check_fields(new_user)
    register_attempt = {}
    if new_user[:first] == ''
      flash[:registration] = "Please fill in your first name."
      return register_attempt
    end
    register_attempt.merge!(:first_name => new_user[:first])

    if new_user[:last] == ''
      flash[:registration] = "Please fill in your last name."
      return register_attempt
    end
    register_attempt.merge!(:last_name => new_user[:last])

    if new_user[:email] == ''
      flash[:registration] = "Please fill in your email."
      return register_attempt
    end
    register_attempt.merge!(:email => new_user[:email])

    if new_user[:username] == ''
      flash[:registration] = "Please fill in a username."
      return register_attempt
    elsif @users_table.find_user(new_user[:username]) != []
      flash[:registration] = "Username is already in use, please choose another."
      return register_attempt
    end
    register_attempt.merge!(:username => new_user[:username])

    if new_user[:password] == ''
      flash[:registration] = "Please create a password."
      return register_attempt
    end
    register_attempt.merge!(:password => new_user[:password])


  end

  get "/" do
    users = @users_table.users

    erb :root, :locals => {:users => users}
  end

  get "/registration" do
    register_attempt = {}
    erb :registration, :locals => {:register_attempt => register_attempt}
  end

  post "/registration" do

    new_user = {
        :first => params[:first_name],
        :last => params[:last_name],
        :email => params[:email],
        :username => params[:username],
        :password => params[:password],
        :confirm_password => params[:confirm_password]}

    register_attempt = check_fields(new_user)

    if register_attempt.count < (new_user.count - 1)
      erb :registration, :locals => {:register_attempt => register_attempt}
    elsif params[:password] != params[:confirm_password]
      flash[:registration] = "Please enter your password identically"
      erb :registration, :locals => {:register_attempt => register_attempt}
    else
      flash[:notice] = "Thank you for registering"
      flash[:registration] = nil
      @users_table.create(params[:username], params[:password])
      redirect "/"
    end
  end

  post "/login" do
    current_user = @users_table.find_by(params[:username], params[:password])
    session[:user_id] = current_user["id"]
    # p "the session id is #{session[:user_id]}"
    flash[:not_logged_in] = true
    flash[:login] = "Welcome, #{params[:username].capitalize}"
    redirect "/"
  end

  post "/logout" do
    session[:user_id] = nil
    redirect "/"
  end

end

