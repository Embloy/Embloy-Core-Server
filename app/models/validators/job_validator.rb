# frozen_string_literal: true

# The JobValidator module contains custom validation rules for a Job object.
# These rules are included in the Job model and run when a Job object is saved.
module Validators
  # The JobValidator module contains custom validation rules for a Job object.
  # These rules are included in the Job model and run when a Job object is saved.
  module JobValidator
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      geocoded_by :latitude_longitude
      after_validation :geocode
      include Visible
      include PgSearch::Model
      # include ActiveModel::Serialization
      paginates_per 48
      max_pages 10
      multisearchable against: %i[title job_type
                                  position key_skills description city postal_code address]
      pg_search_scope :search_for,
                      against: %i[title description position job_type key_skills address city postal_code
                                  start_slot],
                      using: {
                        tsearch: { prefix: true,
                                   any_word: true, dictionary: 'english', normalization: 2 },
                        trigram: { threshold: 0.1 }
                      }
      scope :within_radius, lambda { |lat, lng, rad, lim|
        select("*, ST_Distance(job_value::geometry, ST_SetSRID(ST_MakePoint(#{lat}, #{lng}), 4326)::geography) AS distance")
          .where("ST_DWithin(job_value::geometry, ST_SetSRID(ST_MakePoint(#{lat}, #{lng}), 4326)::geography, #{rad})")
          .order('distance')
          .limit(lim)
      }
      belongs_to :user, counter_cache: true
      has_many :applications, dependent: :delete_all
      has_many :application_attachments,
               dependent: :delete_all
      has_noticed_notifications model_name: 'Notification'
      has_rich_text :description
      has_one_attached :image_url

      validates :title, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                        length: { minimum: 0, maximum: 100, "error": 'ERR_LENGTH', "description": 'Attribute length is invalid' }
      validates :description, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                              length: { minimum: 10, maximum: 1000, "error": 'ERR_LENGTH', "description": 'Attribute length is invalid' }
      validates :start_slot,
                presence: { "error": 'ERR_BLANK',
                            "description": "Attribute can't be blank" }
      validates :longitude, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                            numericality: { "error": 'ERR_INVALID', "description": 'Attribute is malformed or unknown' }
      validates :latitude, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                           numericality: { "error": 'ERR_INVALID', "description": 'Attribute is malformed or unknown' }
      validates :job_notifications, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                                    numericality: { only_integer: true, "error": 'ERR_INVALID', "description": 'Attribute is malformed or unknown' }
      validates :position, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                           length: { minimum: 0, maximum: 100, "error": 'ERR_LENGTH', "description": 'Attribute length is invalid' }
      validates :key_skills, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                             length: { minimum: 0, maximum: 100, "error": 'ERR_LENGTH', "description": 'Attribute length is invalid' }
      validates :duration, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                           numericality: { only_integer: true, greater_than: 0, "error": 'ERR_INVALID', "description": 'Attribute is malformed or unknown' }
      validates :salary, presence: { "error": 'ERR_BLANK', "description": "Attribute can't be blank" },
                         numericality: { only_integer: true, greater_than: 0, "error": 'ERR_INVALID', "description": 'Attribute is malformed or unknown' }
      validates :currency,
                presence: { "error": 'ERR_BLANK',
                            "description": "Attribute can't be blank" }
      validates :job_type,
                presence: { "error": 'ERR_BLANK',
                            "description": "Attribute can't be blank" }
      validates :status,
                inclusion: { in: %w[public private archived], "error": 'ERR_INVALID', "description": 'Attribute is invalid' }, presence: false
      validates :job_type_value,
                presence: { "error": 'ERR_BLANK',
                            "description": "Attribute can't be blank" }

      # validates :postal_code, length: { minimum: 0, maximum: 45, "error": "ERR_LENGTH", "description": "Attribute length is invalid" }
      # validates :country_code, length: { minimum: 0, maximum: 45, "error": "ERR_LENGTH", "description": "Attribute length is invalid" }
      # validates :city, length: { minimum: 0, maximum: 45, "error": "ERR_LENGTH", "description": "Attribute length is invalid" }
      # validates :address, length: { minimum: 0, maximum: 150, "error": "ERR_LENGTH", "description": "Attribute length is invalid" }
      # TODO: @cb Validate allowed_cv_format, so that user has to select at least one option
      validates :allowed_cv_format,
                # inclusion: { in: %w[.pdf .docx .txt .xml], message: { error: "ERR_INVALID", description: "Attribute is invalid" } },
                presence: { message: {
                  error: 'ERR_BLANK', description: "Attribute can't be blank"
                } },
                # format: { with: /\.(pdf|docx|txt|xml)\z/, allow_blank: true, message: { error: "ERR_INVALID", description: "Attribute is invalid" }},
                if: :cv_required?
      validate :image_format_validation
      validate :employer_rating
      validate :boost
      validate :start_slot_validation
      validate :job_type_validation
    end
    # rubocop:enable Metrics/BlockLength

    private

    def job_type_validation
      job_types_file = File.read(Rails.root.join(
                                   'app/helpers', 'job_types.json'
                                 ))
      job_types = JSON.parse(job_types_file)
      # Given job_type is not existent in job_types.json
      return if job_types.key?(job_type) || job_type == 'EMJ'

      errors.add(:job_type,
                 { "error": 'ERR_INVALID',
                   "description": 'Attribute is malformed or unknown' })
    end

    def start_slot_validation
      return unless start_slot - Time.now < -86_400

      errors.add(:start_slot,
                 { "error": 'ERR_INVALID',
                   "description": 'Attribute is malformed or unknown' })
    end

    def image_format_validation
      return unless !image_url.nil? && image_url.attached?

      allowed_formats = %w[image/png image/jpeg
                           image/jpg]
      return if allowed_formats.include?(image_url.blob.content_type)

      errors.add(:image_url,
                 { "error": 'ERR_INVALID',
                   "description": 'must be a PNG, JPG, or JPEG image' })
    end
  end
end
