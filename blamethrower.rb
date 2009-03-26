require 'yaml'
require 'pathname'
require 'rubygems'
require 'sinatra'
require 'activerecord'

configure do
	set :sessions, :true
	set :environment, :production
	ROOT = Pathname.new(File.dirname(__FILE__))
	CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
		
	ActiveRecord::Base.establish_connection(CONFIG['db'][Sinatra::Application.environment.to_s])
	
	(ROOT + "models").children.each {|model| require model }
	require 'lib/sessionauth'
	include Sinatra::SessionAuth
	Sinatra::Application.register Sinatra::SessionAuth
end

get "/" do
	@user = current_user
	if @user
		haml :home
	else
		haml :index
	end
end

get "/sass/:format/:file" do
	content_type 'text/css', :charset => 'utf-8'
	@file = Pathname.new("./views/" + (params[:file] + ".sass"))

	if @file.exist?
		@format = params[:format].intern
		@sass = Sass::Engine.new(@file.read, {:style => @format})
		@sass.render
	else
		raise not_found, "Sass stylesheet not found."
	end
end