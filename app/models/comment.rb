class Comment < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :slot_change_id
  # t.text :content

  belongs_to :user
  belongs_to :slot_change

  attr_accessible :content
end
