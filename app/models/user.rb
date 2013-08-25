class User < ActiveRecord::Base
  # t.string :name

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,
                  :email, :password, :password_confirmation, :remember_me # by devise

  has_one :contact_info
  has_and_belongs_to_many :roles
  has_many :slot_changes

  # @note :security
  # The roles are cached on the object when role? is called the first time.
  def role? role
    @rlz ||= roles.collect{ |r| r.name}
    @rlz.include? role.to_s
  end

end
