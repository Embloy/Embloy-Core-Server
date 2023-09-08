module Api
  module V0
    class ApplicationsController < ApiController
      before_action :verify_access_token
      before_action :verify_path_job_id

      def show
        begin
          verified!(@decoded_token["typ"])
          must_be_owner!(params[:id], @decoded_token["sub"])
          applications = @job.applications.find_by_sql("SELECT * FROM applications a WHERE a.job_id = #{@job.job_id}")
          if applications.empty?
            render status: 204, json: { "applications": applications }
          else
            render status: 200, json: { "applications": applications }
          end
        end
      end

      def create
        begin
          verified!(@decoded_token["typ"])
          job = Job.find(params[:id])
          puts "PARAMS = #{params}"
          puts "PARAMS = #{application_params}"
          puts "PARAMS = #{application_params[:application_text]}"
          application = Application.create!(
            user_id: @decoded_token["sub"],
            job_id: job.job_id,
            application_text: application_params[:application_text],
            created_at: Time.now,
            updated_at: Time.now,
            response: "null"
          )
          begin
            application.user = User.find(@decoded_token["sub"])
          rescue ActiveRecord::RecordNotFound
            raise CustomExceptions::InvalidUser::Unknown
          end

          application.save!
          render status: 200, json: { "message": "Application submitted!" }

        rescue ActiveRecord::RecordNotUnique
          unnecessary_error('application')

        rescue ActiveRecord::RecordNotFound
          raise CustomExceptions::InvalidJob::Unknown

        rescue ActiveRecord::RecordInvalid
          malformed_error('application')

        end
      end

      def accept
        begin
          verified!(@decoded_token["typ"])
          must_be_owner!(params[:id], @decoded_token["sub"])
          job = Job.find(params[:id])
          application = job.applications.where(user_id: params[:application_id]).first

          if application.nil?
            render status: 404, json: { "message": "Not found." }
            return
          end

          if application.status != "1"
            if application_params[:response]
              application.accept(application_params[:response])
            else
              application.accept("ACCEPTED")
            end
          else
            render status: 400, json: { "message": "Already accepted." }
            return
          end

          render status: 200, json: { "message": "Application successfully accepted." }
        rescue ActiveRecord::RecordNotFound
          render status: 404, json: { "message": "Not found." }
        end
      end

      def reject
        begin
          verified!(@decoded_token["typ"])
          must_be_owner!(params[:id], @decoded_token["sub"])
          job = Job.find(params[:id])
          application = job.applications.where(user_id: params[:application_id]).first

          if application.nil?
            render status: 404, json: { "message": "Not found." }
            return
          end
          puts "APPLICATION STATUS = #{application.status}"
          if application.status != "-1"
            if application_params[:response]
              application.reject(application_params[:response])
            else
              application.reject("REJECTED")
            end
          else
            render status: 400, json: { "message": "Already rejected." }
            return
          end

          render status: 200, json: { "message": "Application successfully rejected." }
        rescue ActiveRecord::RecordNotFound
          render status: 404, json: { "message": "Not found." }
        end
      end

      # destroy throws ActiveJob::SerializationError => until resolved there wont be application delete functionality via api
=begin
      def destroy
        if request.headers["HTTP_ACCESS_TOKEN"].nil?
          render status: 400, json: { "access_token": [
            {
              "error": "ERR_BLANK",
              "description": "Attribute can't be blank"
            }
          ]
          }
        else
          begin
            decoded_token = AuthenticationTokenService::Access::Decoder.call(request.headers["HTTP_ACCESS_TOKEN"])[0]
            verified!(decoded_token["typ"])
            job = Job.find(params[:id])
            application = job.applications.find(decoded_token["sub"])



            application = Application.find_by_sql("SELECT * FROM applications a WHERE a.user_id = #{decoded_token["sub"]} and a.job_id = #{params[:id]}")[0]
            application.destroy!




            render status: 200, json: { "message": "Application deleted!" }

          end
        end
        end
=end

      # Todo: Wait for .accept in application.rb implementation and implement methods accordingly

=begin

      def reject
        @job = Job.find(params[:job_id])
        if require_user_be_owner!
          # @application_service.reject(params[:job_id].to_i, params[:application_id].to_i, "REJECTED")
          redirect_to job_applications_path(params[:job_id]), status: :see_other, notice: 'Application has been rejected'
        end
      end

      def reject_all
        @job = Job.find(params[:job_id])
        if require_user_be_owner!
          # @application_service.reject_all(params[:job_id].to_i, "REJECTED")
          redirect_to job_path(@job), status: :see_other, notice: 'All Applications have been rejected'
        end
      end

      private

      def set_job
        @job = Job.find(params[:job_id])
      end
=end

      def application_params
        params.require(:application).permit(:user_id, :application_text, :application_documents, :response, :cv)
      end
    end
  end
end
