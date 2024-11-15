class User < ApplicationRecord
  USER_PARAMS = %i(name email password password_confirmation).freeze
  attr_accessor :remember_token

  before_save :downcase_email

  validates :name, presence: true,
                   length: {maximum: Settings.max_name_length}

  validates :email, presence: true,
                    format: {with: URI::MailTo::EMAIL_REGEXP},
                    length: {maximum: Settings.max_email_length},
                    uniqueness: true

  validates :password, presence: true,
                       length: {minimum: Settings.min_password_length},
                       if: :password

  has_secure_password

  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost:)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def session_token
    remember_digest || remember
  end

  private

  def downcase_email
    email.downcase!
  end
end
