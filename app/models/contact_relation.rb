class ContactRelation < ActiveRecord::Base
  # t.integer :organisation_id
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :contact_id

  belongs_to :organisation
  belongs_to :contact
  belongs_to :parent, :polymorphic => true

  attr_accessible :organisation, :organisation_id, :parent_type, :parent_id, :parent

  def can_delete?
    true 
  end  
end
