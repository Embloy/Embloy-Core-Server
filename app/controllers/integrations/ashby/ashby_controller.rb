# frozen_string_literal: true

require 'net/http/post/multipart'
require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'mawsitsit'

module Integrations
  module Ashby
    # AshbyController handles Ashby-related actions
    class AshbyController < IntegrationsController
      ASHBY_POST_FORM_URL = 'https://api.ashbyhq.com/applicationForm.submit'
      ASHBY_FETCH_POSTING_URL = 'https://api.ashbyhq.com/jobPosting.info'
      ASHBY_FETCH_POSTINGS_URL = 'https://api.ashbyhq.com/jobPosting.list'

      # Reference: https://developers.ashbyhq.com/reference/applicationformsubmit
      def self.post_form(posting_id, application, application_params, client) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        url = URI(ASHBY_POST_FORM_URL)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        api_key = fetch_token(client, 'ashby', 'api_key')
        field_submissions = application.application_answers.map do |answer|
          if answer.application_option.question_type == 'file'
            file_key = "file_#{answer.application_option_id}"
            { path: answer.application_option.ext_id.split('__').last, value: file_key }
          else
            formatted_answer = format_answer(answer)

            { path: answer.application_option.ext_id.split('__').last, value: formatted_answer }
          end
        end

        form_data = { 'jobPostingId' => posting_id, 'applicationForm' => { fieldSubmissions: field_submissions }.to_json }

        # Add files to form_data
        application.application_answers.each do |answer|
          next unless answer.application_option.question_type == 'file'

          application_answer_params = application_params[:application_answers].permit!.to_h.find do |_, a|
            a[:application_option_id].to_i == answer.application_option_id
          end&.last

          next unless application_answer_params

          file = application_answer_params[:file]
          file_key = "file_#{answer.application_option_id}" # Match the key used in field_submissions
          form_data[file_key] = UploadIO.new(file.tempfile, file.content_type, file.original_filename)
        end

        request = Net::HTTP::Post::Multipart.new(url.path, form_data)

        request['Accept'] = 'application/json'
        request['Authorization'] = "Basic #{Base64.strict_encode64("#{api_key}:")}"

        response = http.request(request)

        body = JSON.parse(response.body)
        response = Net::HTTPBadRequest.new('1.1', '400', 'Bad Request', body['errors']) if response == Net::HTTPSuccess && body['success'] == false

        application.update!(ext_id: "ashby__#{body['results']['submittedFormInstance']['id']}") if response.is_a?(Net::HTTPSuccess) && body['success'] == true

        handle_application_response(response)
      end

      # Reference: https://developers.ashbyhq.com/reference/jobpostinginfo
      def self.fetch_posting(posting_id, client, job)
        response = make_request(ASHBY_FETCH_POSTING_URL, client, 'post', { jobPostingId: posting_id })
        case response
        when Net::HTTPSuccess
          body = JSON.parse(response.body)
          raise CustomExceptions::InvalidInput::Quicklink::Request::Malformed unless body['success'] == true

          config = JSON.parse(File.read('app/controllers/integrations/ashby/ashby_config.json'))
          config['city'].gsub!('ASHBY_SECRET', fetch_token(client, 'ashby', 'api_key').to_s)
          job = Mawsitsit.parse(body, config, true)
          job['job_slug'] = "ashby__#{job['job_slug']}"
          job['user_id'] = client.id.to_i
          handle_internal_job(client, job)
        when Net::HTTPBadRequest
          raise CustomExceptions::InvalidInput::Quicklink::Request::Malformed and return
        when Net::HTTPForbidden
          raise CustomExceptions::InvalidInput::Quicklink::Request::Forbidden and return
        when Net::HTTPUnauthorized
          raise CustomExceptions::InvalidInput::Quicklink::ApiKey::Unauthorized and return
        end
      end

      # Reference: https://developers.ashbyhq.com/reference/jobpostinglist
      def self.synchronize(client)
        response = make_request(ASHBY_FETCH_POSTINGS_URL, client)
        case response
        when Net::HTTPSuccess
          body = JSON.parse(response.body)
          raise CustomExceptions::InvalidInput::Quicklink::Request::Malformed unless body['success'] == true

          data = JSON.parse(response.body)['results']
          data.each do |job|
            config = JSON.parse(File.read('app/controllers/integrations/ashby/ashby_config.json'))
            config['city'].gsub!('ASHBY_SECRET', fetch_token(client, 'ashby', 'api_key').to_s)
            parsed_job = Mawsitsit.parse({ results: job }, config, true)
            parsed_job['job_slug'] = "ashby__#{parsed_job['job_slug']}"
            parsed_job['user_id'] = client.id.to_i
            parsed_job['application_options_attributes'] = []
            handle_internal_job(client, parsed_job)
          end
        when Net::HTTPBadRequest
          raise CustomExceptions::InvalidInput::Quicklink::Request::Malformed and return
        when Net::HTTPForbidden
          raise CustomExceptions::InvalidInput::Quicklink::Request::Forbidden and return
        when Net::HTTPUnauthorized
          raise CustomExceptions::InvalidInput::Quicklink::ApiKey::Unauthorized and return
        end
      end

      def self.make_request(url, client, method = 'post', body = nil)
        uri = URI.parse(url)
        request = Net::HTTP.const_get(method.capitalize).new(uri)
        api_key = fetch_token(client, 'ashby', 'api_key')
        request['Authorization'] = "Basic #{Base64.strict_encode64("#{api_key}:")}"
        request['Content-Type'] = 'application/json'
        request.body = body.to_json if body

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def self.format_answer(answer)
        case answer.application_option.question_type
        when 'yes_no'
          answer.answer == 'Yes'
        when 'number', 'score'
          answer.answer.to_i
        when 'multiple_choice'
          begin
            JSON.parse(answer.answer)
          rescue JSON::ParserError
            []
          end
        else
          answer.answer
        end
      end
    end
  end
end
