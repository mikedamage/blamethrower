require 'yaml'
require 'pathname'
require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'haml'
require 'sass'
require 'json'

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

helpers do
	
end

get "/" do
	@user = current_user
	if @user
		@blames_from_others = Blame.find(:all, :conditions => {:target_user => @user.id})
		@my_blames = Blame.find(:all, :conditions => {:user_id => @user.id})
		haml :home
	else
		haml :index
	end
end

get "/user/:name" do
	@current_user = current_user
	@user = User.find(:first, :conditions => {:name => params[:name]})
	if @user
		haml :user
	else
		raise not_found, "User #{params[:name]} not found"
	end
end

get '/autosuggest/:name' do
	content_type "application/json", :charset => "utf-8"
	@suggestions = User.find(:all, :conditions => ['name LIKE "%?%"', params[:name]])
	@json = Array.new
	@suggestions.each do |suggestion|
		@json << {"name" => suggestion.name, "id" => suggestion.id.to_s}
	end
	"#{@json.to_json}"
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

post "/blame" do
	target_id = params[:id]
	user = current_user
	blame = Blame.new({:user_id => user, :target_user => id})
	blame.reason = params[:reason] if params[:reason]
	
	if blame.save
		
	else
		
	end
end