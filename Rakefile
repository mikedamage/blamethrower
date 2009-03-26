require 'yaml'
require 'pathname'
require 'rubygems'
require 'activerecord'

task :development do
	@env = "development"
end

task :production do
	@env = "production"
end

task :migrate do
	if @env
		root = Pathname.new(File.dirname(__FILE__))
		config = YAML.load_file((root + "config.yml").to_s)
		ActiveRecord::Base.establish_connection(config["db"][@env])
		(root + "models").children.each {|model| require model }
		(root + "db/migrations").children.each {|migration| require migration }
		$stdout.puts "Running #{@env} migrations..."
		SetupUsers.up unless User.table_exists?
		SetupBlames.up unless Blame.table_exists?
	else
		$stdout.puts "Please specify an environment first. (i.e. rake production migrate)"
	end
end