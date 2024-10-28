class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true, length:
  {maximum: ENV["MAX_NAME_LENGTH"].to_i}
  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP},
  length: {maximum: ENV["MAX_EMAIL_LENGTH"].to_i}, uniqueness: true
  validates :password, presence: true,
length: {minimum: ENV["MIN_PASSWORD_LENGTH"]}, if: :password

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
