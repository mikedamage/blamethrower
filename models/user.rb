class User < ActiveRecord::Base
	has_many :blames
	
	validates_presence_of :name, :on => :create
	validates_presence_of :email, :on => :create, :message => "can't be blank"
	validates_length_of :password, :within => 4..100, :on => :create, :message => "must be at least 4 characters long"
	validates_uniqueness_of :name, :on => :create, :message => "already exists"
	
	
	def self.authenticate(user, pass)
		current_user = self.find(:first, :conditions => {:name => user})
		return nil if current_user.nil?
		return current_user if User.encrypt(pass) == current_user.password
		nil
	end
	
	def before_save
		self.password = User.encrypt(self.password)
	end
	
	protected
	def self.encrypt(str)
		return Digest::SHA1.hexdigest(str)
	end
end