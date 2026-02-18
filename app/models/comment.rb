# frozen_string_literal: true

class Comment < ApplicationRecord
  # Associations
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :parent_comment, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment", foreign_key: :parent_comment_id,
           dependent: :destroy, inverse_of: :parent_comment

  # Validations
  validates :body, presence: true

  # Scopes
  scope :chronological, -> { order(created_at: :asc) }
  scope :reverse_chronological, -> { order(created_at: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
  scope :top_level, -> { where(parent_comment_id: nil) }

  def reply?
    parent_comment_id.present?
  end

  def top_level?
    parent_comment_id.nil?
  end
end
