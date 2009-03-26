require 'yaml'
require 'pathname'
require 'rubygems'
require 'sinatra'
require 'activerecord'

configure do
	set :sessions, :true
	ROOT = Pathname.new(File.dirname(__FILE__))
	CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
		
	ActiveRecord::Base.establish_connection(CONFIG['database'][Sinatra::Application.environment.to_s])
	
	(ROOT + "models").children.each {|model| require model }
end

get "/" do
	"Hello"
end