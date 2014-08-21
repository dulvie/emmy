class Document < ActiveRecord::Base

  # t.integer :organisation_id 
  # t.string  :parent_type
  # t.integer :parent_id
  # t.integer :user_id
  # t.string  :name

  has_attached_file :upload
  belongs_to :organisation
  belongs_to :user
  belongs_to :parent, polymorphic: true

  attr_accessible :name, :user, :parent, :user_id, :parent_id, :parent_type, :organisation, :upload

  validates_attachment_content_type :upload, :content_type => ['application/pdf', 'image/jpeg', 'image/png']
  VALID_PARENT_TYPES = ['Purchase', 'nil']

  # Callbacks
  before_save :name_fallback

  # Callback: before_save
  def name_fallback
    if self.name && !self.name.empty?
      true
    else
      self.name = self.upload_file_name
    end
  end


  # For ApplicationHelper#delete_button
  def can_delete?
    true
  end

  def parent_name
    parent.parent_name
  end
end
