class User < ActiveRecord::Base
  # t.string :name
  # t.string :email,              null: false, default: ""
  # t.string :encrypted_password, null: false, default: ""
  # t.string   :reset_password_token
  # t.datetime :reset_password_sent_at
  # t.datetime :remember_created_at
  enum default_locale: [:en, :se]
  LOCALE_EN = 0
  LOCALE_SE = 1

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :default_locale,
                  :email, :password, :password_confirmation, :remember_me # by devise

  has_and_belongs_to_many :roles
  has_one :contact_relation, as: :parent
  has_one :contacts, through: :contact_relation

  # @note :security
  # The roles are cached on the object when role? is called the first time.
  def role?(role)
    @rlz ||= roles.collect { |r| r.name }
    @rlz.include? role.to_s
  end

  def can_delete?
    true
  end

  def parent_name
    name
  end

  # Used by Devise
  def active_for_authentication?
    super and !role? :suspended
  end
end
