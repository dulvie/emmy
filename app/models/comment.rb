class Comment < ActiveRecord::Base
  # t.text :body
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :user_id

  belongs_to :user
  belongs_to :parent, polymorphic: true

  validates :body, presence: true

  attr_accessible :body, :user, :parent, :user_id, :parent_id, :parent_type

  VALID_PARENT_TYPES = ['Customer', 'Supplier', 'Warehouse', 'Manual', 'Transfer', 'Import', 'Production', 'nil']

  # For ApplicationHelper#delete_button
  def can_delete?
    true
  end

  def parent_name
    parent.parent_name
  end
end
