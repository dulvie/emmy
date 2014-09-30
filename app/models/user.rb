class User < ActiveRecord::Base
  # t.string :name
  # t.string :email,              null: false, default: ""
  # t.string :encrypted_password, null: false, default: ""
  # t.string   :reset_password_token
  # t.datetime :reset_password_sent_at
  # t.datetime :remember_created_at
  # t.integer :default_locale, default: 0 # defaults to english
  # t.integer :current_organisation_id, default: 0 # defaults to no organisation

  enum default_locale: [:en, :se]
  LOCALE_EN = 0
  LOCALE_SE = 1

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :default_locale,
                  :email, :password, :password_confirmation, :remember_me # by devise

  has_many :organizations
  has_many :organization_roles
  has_one :contact_relation, as: :parent
  has_one :contacts, through: :contact_relation

  # Nope, this is not the way to use this...
  def can_delete?
    false
  end

  # @todo Update comment with better description on why #parent_name is needed.
  # Probably used by contact_relation controller and/or view.
  # This still doesn't make sense, 'parent_name' should be name of the parent
  # this returns the name of the current object.
  def parent_name
    name
  end

  def is_superadmin?
    @is_superadmin ||= organization_roles.where(organisation_id: 0).where(name: 'superadmin').count > 0
  end

  # Used by Devise
  def active_for_authentication?
    super and !role? :suspended
  end


end
