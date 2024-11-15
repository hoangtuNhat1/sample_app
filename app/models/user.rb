class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  before_create :create_activation_digest
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
  USER_PARAMS = %i(name email password password_confirmation).freeze

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

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def session_token
    remember_digest || remember
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
