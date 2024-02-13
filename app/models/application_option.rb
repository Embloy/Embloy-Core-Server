# frozen_string_literal: true

# The ApplicationOption class is responsible for validating the application options associated with a job.
# It includes validations for the presence and length of the question, the presence and inclusion of the question_type,
# the inclusion of the required field, and the presence, length, and type of the options.
# It also includes custom validations for the presence, count, length, and type of the options if the question_type is 'single_choice' or 'multiple_choice'.
class ApplicationOption < ApplicationRecord
  belongs_to :job
  acts_as_paranoid
  VALID_QUESTION_TYPES = %w[yes_no text link single_choice multiple_choice].freeze

  serialize :options, Array
  validates :question, presence: { error: 'ERR_BLANK', description: "Attribute can't be blank" },
                       length: { minimum: 0, maximum: 200, error: 'ERR_LENGTH', description: 'Attribute length is invalid' }
  validates :question_type,
            presence: { error: 'ERR_BLANK', description: "Attribute can't be blank" },
            inclusion: { in: VALID_QUESTION_TYPES, error: 'ERR_INVALID', description: 'Attribute is invalid' }
  validates :required, inclusion: { in: [true, false], error: 'ERR_INVALID', description: 'Attribute is invalid' }
  validates :options, presence: { error: 'ERR_BLANK', description: "Attribute can't be blank" }, if: :options_required?
  validates :options, length: { maximum: 25, message: 'cannot have more than 25 options' }, if: :options_required?
  validate :options_length_validation, if: :options_required?
  validate :options_count_validation, if: :options_required?
  validate :options_type_validation
  validate :options_presence_validation, if: :options_required?

  enum question_type: { yes_no: 'yes_no', text: 'text', link: 'link', single_choice: 'single_choice', multiple_choice: 'multiple_choice' }

  def options_required?
    %w[single_choice multiple_choice].include?(question_type)
  end

  private

  def options_presence_validation
    return unless options.blank?

    errors.add(:options, 'Options cannot be blank for single_choice or multiple_choice')
  end

  def options_count_validation
    return unless options.size > 25

    job.errors.add(:options, 'At most 25 options can be set')
  end

  def options_length_validation
    return unless options.any? { |option| option.length > 50 }

    job.errors.add(:options, 'Each option can be at most 50 characters long')
  end

  def options_type_validation
    return if options.is_a?(Array)

    job.errors.add(:options, 'Options must be an array')
  end
end
