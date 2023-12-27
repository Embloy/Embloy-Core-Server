# frozen_string_literal: true

# The ApplicationHelper module provides helper methods used across the application.
module ApplicationHelper
  def self.allowed_cv_formats_for_form(allowed_formats)
    formats_mapping = {
      '.pdf' => 'application/pdf',
      '.txt' => 'text/plain',
      '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.xml' => 'text/xml'
      # TODO: Add more mappings if needed (then update job model, schema.rb and postgres db)
    }
    allowed_formats.map do |format|
      formats_mapping[format]
    end
  end
end
