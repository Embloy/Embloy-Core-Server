class User < ApplicationRecord
  has_secure_password
  has_one :preferences, dependent: :delete
  has_many :jobs, dependent: :delete_all
  has_many :reviews, dependent: :delete_all
  has_many :notifications, as: :recipient, dependent: :destroy

  validates :email, presence: { "error": "ERR_BLANK", "description": "Attribute can't be blank" }, uniqueness: { "error": "ERR_TAKEN", "description": "Attribute exists" }, format: { with: /\A[^@\s]+@[^@\s]+\z/, "error": "ERR_INVALID", "description": "Attribute is malformed or unknown" }
  validates :first_name, presence: { "error": "ERR_BLANK", "description": "Attribute can't be blank" }, uniqueness: false
  validates :last_name, presence: { "error": "ERR_BLANK", "description": "Attribute can't be blank" }, uniqueness: false
  # TODO: UNDERSTAND UPDATABLE?
  validates :password, presence: { "error": "ERR_BLANK", "description": "Attribute can't be blank" },
            length: { minimum: 8, maximum: 72, "error": "ERR_LENGTH", "description": "Attribute length is invalid" },
            if: :password_required?

  validates :password_confirmation, presence: { "error": "ERR_BLANK", "description": "Attribute can't be blank" },
            length: { minimum: 8, maximum: 72, "error": "ERR_LENGTH", "description": "Attribute length is invalid" },
            if: :password_required?
  validates :application_notifications, presence: true
  validates :longitude, presence: false
  validates :latitude, presence: false
  validates :country_code, presence: false
  validates :postal_code, presence: false
  validates :city, presence: false
  validates :address, presence: false
  validates :user_type, inclusion: { in: %w[company private], "error": "ERR_INVALID", "description": "Attribute is invalid" }, presence: false
  validates :user_role, inclusion: { in: %w[admin editor developer moderator verified spectator], "error": "ERR_INVALID", "description": "Attribute is invalid" }, presence: false
  validates :image_url, presence: false

  validate :country_code_validation
  validate :image_format_validation

  def full_name
    "#{first_name} #{last_name}"
  end

  def is_verified?
    [true, false].sample
  end

  def age
    now = Time.now.utc.to_date
    now.year - self.date_of_birth.year - ((now.month > self.date_of_birth.month || (now.month == self.date_of_birth.month && now.day >= self.date_of_birth.day)) ? 0 : 1) unless self.date_of_birth.nil?
  end

  private

  def password_required?
    password.present? || password_confirmation.present? || new_record?
  end

  def country_code_validation
    unless country_code.nil? || country_code.empty? || IsoCountryCodes.find(country_code)
      errors.add(:country_code, "is not a valid ISO country code")
    end
  end

  def image_format_validation
    return unless image_url.attached?

    allowed_formats = %w[image/png image/jpeg image/jpg]
    unless allowed_formats.include?(image_url.blob.content_type)
      errors.add(:image_url, "must be a PNG, JPG, or JPEG image")
    end
  end

end