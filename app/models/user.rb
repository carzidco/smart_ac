class User < ActiveRecord::Base

  include Deviceable::InstanceMethods

  has_secure_password
  has_many :devices, :dependent => :destroy

end
