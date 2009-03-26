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
	require 'sessionauth'
	include Sinatra::SessionAuth
	Sinatra::Application.register Sinatra::SessionAuth
end

get "/" do
	"BlameThrower"
end