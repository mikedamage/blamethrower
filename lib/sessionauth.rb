require 'sinatra/base'
require 'erb'
require 'digest'
require 'pony'

module Sinatra
  module SessionAuth
		WELCOME_MSG = <<-END
Hello, <%= name %>, and welcome to the BlameThrower community!	
Please hold onto this information for your records.

User Name: <%= name %>
Email: <%= email %>
Password: <%= pass %>

Happy Blaming!

- The BlameThrower Team
END
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
			
			def current_user
				if session[:authorized]
					User.find(session[:user_id])
				else
					nil
				end
			end
    end

    def self.registered(app)
      app.helpers SessionAuth::Helpers

      app.get '/login' do
				@flash = session[:flash] ? session[:flash] : ""
        haml :login
      end

      app.post '/login' do
				@user = User.find(:first, :conditions => {:name => params[:name]})
				crypted_password = Digest::SHA1.hexdigest(params[:pass])
        if @user.password == crypted_password
          session[:authorized] = true
					session[:user_id] = @user.id
					session[:flash] = "Welcome, #{@user.name}!"
          redirect '/'
        else
          session[:authorized] = false
					session[:flash] = "Login Error. Please Try Again!"
          redirect '/login'
        end
      end
			
			app.get '/logout' do
				logout!
				session[:flash] = "Logout Successful"
				redirect '/'
			end
			
			app.get '/signup' do
				@flash = session[:flash] ? session[:flash] : ""
				haml :signup
			end
			
			app.post '/signup' do
				name = params[:name]
				pass = params[:pass]
				pass_confirm = params[:pass_confirm]
				email = params[:email]
				if pass == pass_confirm
					user = User.new({
						:name => name,
						:email => email,
						:password => pass
					})
					if user.save
						# TODO: Use the Pony gem to send a confirmation email w/ password before it's irreversibly encrypted.
						if Sinatra::Application.environment.to_s == "production"
							welcome_message = ERB.new(WELCOME_MSG).result(binding)
							# Pony.mail({
							# 								:to => email,
							# 								:from => "mike@fifthroomcreative.com",
							# 								:via => :sendmail,
							# 								:subject => "Welcome to BlameThrower",
							# 								:body => welcome_message
							# 							})
						end
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
