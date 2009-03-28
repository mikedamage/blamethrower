class Blame < ActiveRecord::Base
	belongs_to :user
	
	def before_save
		target_user_name = User.find(:first, :conditions => {:id => this.target_id}).name
		this.target_name = target_user_name
	end
end