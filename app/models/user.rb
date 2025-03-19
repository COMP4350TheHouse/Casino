# This model represents a user account
class User < ApplicationRecord
  has_secure_password
  has_many :wagers, dependent: :destroy
  has_many :sessions, dependent: :destroy

  normalizes :username, with: lambda(&:strip)
  validates :username,
            presence: true,
            format: { with: /\A[a-zA-Z0-9_-]+\z/i, message: "must only contain letters, numbers, hyphens, or underscores." },
            length: { in: 4..16, message: "must be between 4 and 16 characters long." },
            uniqueness: { case_sensitive: false, message: "already exists." }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address,
            presence: true,
            format: { with: /\A([\w+-].?)+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "must be valid." },
            uniqueness: { case_sensitive: false, message: "is already in use." }
  validates :password_digest,
            presence: true
  validates :balance,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
