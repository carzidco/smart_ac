#TODO: 
# Using something like GraphQL could solve the duplication about api and web endpoints
# Another nice solution could be create a base class that infer the request origin and get the result based on it
# Finally a cleaner way could be create a js interface like a ServiceBase.js file and hit the api via axios or fetch an standardized it using only API call for everything

class UsersController < ApplicationController

  # loads the signup page
  # does not let a logged in user view the signup page
  get '/signup' do
    if !logged_in?
      erb :'users/create_user', :layout => :'not_logged_in_layout'
    else
      redirect_to_home_page
    end
  end

  post '/signup' do
    if params["username"].empty? || params["email"].empty? || params["password"].empty?
      flash[:message] = "Pleae don't leave blank content"
      redirect to '/signup'
    else
      user = User.find_by(username: params["username"]);

      if user.present?
        flash[:message] = "User already exists, please pick another"
        redirect to '/signup'
      end

      @user = User.create(username: params["username"], email: params["email"], password: params["password"])
      session[:user_id] = @user.id
      flash[:message] = "Ready to add devices"
      redirect_to_home_page
    end
  end

  post '/api/signup' do
    params = JSON.parse request.body.read
    params["email"] = params["username"] + '@temporary-email-for-smart-ac.com'
    
    if params["username"].empty? || params["email"].empty? || params["password"].empty?
      result = {
        :message => "Pleae don't leave blank content"
      }
      return json(result)
    else
      user = User.find_by(username: params["username"]);
      
      if user.present?
        result = {
          :message => "User already exists, please pick another"
        }
        status 500
        return json(result)
      end

      @user = User.create(username: params["username"], email: params["email"], password: params["password"])
      datetbc = Time.now
      @device = Device.create(serial_number: params["serial_number"], created_at: datetbc, firmware_version: params["firmware_version"], user_id:@user.id)
      session[:user_id] = @user.id

      status 201
      return json(session[:user_id])
    end
  end

  # loads the login page
  # does not let user view login page if already logged in
  get '/login' do
    if logged_in?
      redirect_to_home_page
    else
      erb :index, :layout => :'not_logged_in_layout'
    end
  end

  post '/login' do
    @user = User.find_by(username:params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to_home_page
    else
      flash[:message] = "We can't find you, Please try again"
      redirect_if_not_logged_in
    end
  end

  post '/api/login' do
    params = JSON.parse request.body.read
    if params["username"].present? && params["password"].present?
      @user = User.find_by(username:params["username"])
      if @user && @user.authenticate(params["password"])
        session[:user_id] = @user.id
        status 200
        return json(session[:user_id])
      else
        result = {
          error: "We can't find you, Please try again"
        }
        status 500
        return json(result)
      end
    end
  end

  # lets an user edit info only if logged in
  get '/users/:id/edit' do
    if logged_in?
        erb :'users/edit_user'
    else
      redirect_if_not_logged_in
    end
  end

  # does not let a user edit with blank content
  patch '/users/:id' do
    if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
      @user = User.find(params[:id])
      @user.update(username:params[:username], email:params[:email], password:params[:password])
      flash[:message] = "Account Updated"
      redirect to "/users/#{@user.id}"
    else
      flash[:message] = "Please don't leave blank content"
      redirect to "/users/#{params[:id]}/edit"
    end
  end

  # displays user info if logged in
  get '/users/:id' do
    if logged_in?
      erb :'users/show'
    else
      redirect_if_not_logged_in
    end
  end

  # lets a user delete its own account if they are logged in
  delete '/users/:id/delete' do
    if logged_in?
      current_user.delete
      redirect to "/logout"
    else
      redirect_if_not_logged_in
    end
  end

  get '/users' do
    if logged_in?
      return json(User.all)
    else
      redirect to "/"
    end
  end

  # lets a user logout if they are already logged in
  # does not let a user logout if not logged in
  get '/logout' do
    if logged_in?
      session.clear
      redirect_if_not_logged_in
    else
      redirect to "/"
    end
  end

end
