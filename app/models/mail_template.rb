class MailTemplate < ActiveRecord::Base
  # t.string   :name
  # t.string   :template_type
  # t.string   :from
  # t.string   :to
  # t.string   :subject
  # t.string   :attachment
  # t.text     :text
  # t.integer  :organization_id
  # t.timestamps

  TEMPLATE_TYPES = ['invoice', 'reminder']

  attr_accessible :name, :template_type, :from, :to, :subject, :attachment, :text

  belongs_to :organization

  validates :name, presence: true, uniqueness: { scope: :organization_id}
  validates :template_type, inclusion: { in: TEMPLATE_TYPES }
  validates :from, presence: true
  validates :to, presence: true
  validates :subject, presence: true
  validates :text, presence: true

  scope :invoice, -> { where(template_type: 'invoice') }
  scope :reminder, -> { where(template_type: 'reminder') }

  def can_delete?
    true
  end
end
