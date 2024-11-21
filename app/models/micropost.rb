class Micropost < ApplicationRecord
  PERMITTED_PARAMS = [:content, :image].freeze

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: Settings.default.image.size
  end

  allowed_image_types = Settings.default.image.type

  validates :content,
            presence: true,
            length: {maximum: Settings.micropost.content.max_len}
  validates :image,
            content_type: {
              in: allowed_image_types,
              message: I18n.t("microposts.image_format")
            },
            size: {
              less_than: Settings.default.image.fileSize.megabytes,
              message: I18n.t("microposts.image_size")
            }
  scope :newest, ->{order created_at: :desc}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
end
