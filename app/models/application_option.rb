# frozen_string_literal: true

# The ApplicationOption class is responsible for validating the application options associated with a job.
# It includes validations for the presence and length of the question, the presence and inclusion of the question_type,
# the inclusion of the required field, and the presence, length, and type of the options.
# It also includes custom validations for the presence, count, length, and type of the options if the question_type is 'single_choice' or 'multiple_choice'.
class ApplicationOption < ApplicationRecord
  belongs_to :job, counter_cache: true
  acts_as_paranoid
  VALID_QUESTION_TYPES = %w[yes_no short_text long_text number link single_choice multiple_choice date location file].freeze
  ALLOWED_FILE_TYPES = %w[pdf doc docx txt rtf odt jpg jpeg png gif bmp tiff tif svg mp4 avi mov wmv flv mkv webm ogg mp3 wav wma aac m4a zip rar tar 7z gz bz2 xls xlsx ods ppt pptx xml].freeze
  # MIME type to file extension mapping
  MIME_TYPE_MAPPING = {
    'application/pdf' => 'pdf',
    'application/msword' => 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'text/plain' => 'txt',
    'application/rtf' => 'rtf',
    'application/vnd.oasis.opendocument.text' => 'odt',
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/bmp' => 'bmp',
    'image/tiff' => 'tiff',
    'image/svg+xml' => 'svg',
    'video/mp4' => 'mp4',
    'video/vnd.avi' => 'avi',
    'video/quicktime' => 'mov',
    'video/x-ms-wmv' => 'wmv',
    'video/x-flv' => 'flv',
    'video/x-matroska' => 'mkv',
    'video/webm' => 'webm',
    'audio/ogg' => 'ogg',
    'audio/mpeg' => 'mp3',
    'audio/wav' => 'wav',
    'audio/x-ms-wma' => 'wma',
    'audio/aac' => 'aac',
    'audio/mp4' => 'm4a',
    'application/zip' => 'zip',
    'application/x-rar-compressed' => 'rar',
    'application/x-tar' => 'tar',
    'application/x-7z-compressed' => '7z',
    'application/gzip' => 'gz',
    'application/x-bzip2' => 'bz2',
    'application/vnd.ms-excel' => 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx',
    'application/vnd.oasis.opendocument.spreadsheet' => 'ods',
    'application/vnd.ms-powerpoint' => 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
    'application/xml' => 'xml'
  }.freeze

  serialize :options, Array
  before_validation :set_default_ext_id, on: %i[create update], if: -> { ext_id.blank? && deleted_at.nil? }
  before_validation :set_default_file_options

  validates :question, presence: { error: 'ERR_BLANK', description: "Attribute can't be blank" },
                       length: { minimum: 0, maximum: 500, error: 'ERR_LENGTH', description: 'Attribute length is invalid' }
  validates :question_type,
            presence: { error: 'ERR_BLANK', description: "Attribute can't be blank" },
            inclusion: { in: VALID_QUESTION_TYPES, error: 'ERR_INVALID', description: 'Attribute is invalid' }
  validates :required, inclusion: { in: [true, false], error: 'ERR_INVALID', description: 'Attribute is invalid' }
  validates :options, presence: { error: 'ERR_BLANK', description: "Attribute can't be blank" }, if: :options_required?
  validates :options, length: { maximum: 50, message: 'cannot have more than 50 options' }, if: :options_required?
  validate :options_length_validation, if: :options_required?
  validate :options_count_validation, if: :options_required?
  validate :options_type_validation
  validate :options_presence_validation, if: :options_required?
  validates :options, length: { minimum: 0, maximum: 100, error: 'ERR_LENGTH', description: 'Attribute length is invalid' }
  validate :file_type_validation, if: -> { question_type == 'file' }

  enum question_type: { yes_no: 'yes_no', short_text: 'short_text', long_text: 'long_text', number: 'number', date: 'date', location: 'location', link: 'link', single_choice: 'single_choice',
                        multiple_choice: 'multiple_choice', file: 'file' }

  with_options unless: :custom_validation_context? do
    validates :ext_id, uniqueness: { scope: :job_id, error: 'ERR_UNIQUE', description: 'Should be unique per job' }, on: %i[create update], if: -> { deleted_at.nil? }
  end

  def custom_validation_context?
    @custom_validation_context
  end

  def self.validate(attributes)
    option = new(attributes)
    option.instance_variable_set(:@custom_validation_context, true)
    option.valid?
    option.errors
  end

  def options_required?
    %w[single_choice multiple_choice].include?(question_type)
  end

  private

  def options_presence_validation
    return unless options.blank?

    errors.add(:options, 'Options cannot be blank for single_choice or multiple_choice')
  end

  def options_count_validation
    return unless options.size > 50

    job.errors.add(:options, 'At most 50 options can be set')
  end

  def options_length_validation
    return unless options.any? { |option| option.length > 100 }

    job.errors.add(:options, 'Each option can be at most 100 characters long')
  end

  def options_type_validation
    return if options.is_a?(Array)

    job.errors.add(:options, 'Options must be an array')
  end

  def set_default_file_options
    self.options = ['pdf'] if options.blank? && question_type == 'file'
  end

  def file_type_validation
    return if options.all? { |option| ALLOWED_FILE_TYPES.include?(option) }

    errors.add(:options, "File types must be one of: #{ALLOWED_FILE_TYPES.join(', ')}")
  end

  def set_default_ext_id
    self.ext_id = "embloy__#{SecureRandom.uuid}"
  end
end
