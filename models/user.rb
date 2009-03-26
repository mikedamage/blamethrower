class User < ActiveRecord::Base
	has_many :blames
end