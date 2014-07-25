class Document < ActiveRecord::Base

  # t.string  :parent_type
  # t.integer :parent_id
  # t.integer :user_id
  # t.string  :name

  has_attached_file :upload
  belongs_to :user
  belongs_to :parent, polymorphic: true

  attr_accessible :name, :user, :parent, :user_id, :parent_id, :parent_type, :upload

  validates_attachment_content_type :upload, :content_type => ["application/pdf"]
  VALID_PARENT_TYPES = ['Purchase', 'nil']

  # For ApplicationHelper#delete_button
  def can_delete?
    true
  end

  def parent_name
    parent.parent_name
  end
end
