require 'sinatra/base'
require 'digest'

module Sinatra
  module SessionAuth

    module Helpers
      def authorized?
        session[:authorized]
      end

      def authorize!
        redirect '/login' unless authorized?
      end

      def logout!
        session[:authorized] = false
      end
    end

    def self.registered(app)
      app.helpers SessionAuth::Helpers

      app.get '/login' do
        haml :login
      end

      app.post '/login' do
				@user = User.find(:first, :conditions => {:name => params[:user]})
				crypted_password = Digest::SHA1.hexdigest(params[:pass])
        if @user && @user.password == crypted_password
          session[:authorized] = true
					session[:flash] = "Welcome, #{@user.name}!"
          redirect '/'
        else
          session[:authorized] = false
          redirect '/login'
        end
      end
			
			app.get '/signup' do
				haml :signup
			end
			
			app.post '/signup' do
				name = params[:name]
				pass = params[:pass]
				pass_confirm = params[:pass_confirm]
				email = params[:email]
				if pass == pass_confirm
					user = User.new
					user.name = name
					user.password = password
					user.email = email
					if user.save
						session[:flash] = "Signup successful! Try logging in now."
						redirect '/login'
					else
						session[:flash] = "There was a problem processing your registration. Please try again."
						redirect '/signup'
					end
				else
					session[:flash] = "Passwords don't match"
					redirect '/signup'
				end
			end
    end
  end

  register SessionAuth
end
