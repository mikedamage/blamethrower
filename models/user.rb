class User < ActiveRecord::Base
	has_many :blames
	
	def self.authenticate(user, pass)
		current_user = self.find(:first, :conditions => {:name => user})
		return nil if current_user.nil?
		return current_user if User.encrypt(pass) == current_user.password
		nil
	end
	
	def password=(pass)
		password = User.encrypt(pass)
		self.password = password
	end
	
	protected
	def self.encrypt(str)
		return Digest::SHA1.hexdigest(str)
	end
end