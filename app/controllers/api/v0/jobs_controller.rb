require_relative '../../lib/feed_generator.rb'
module Api
  module V0
    class JobsController < ApplicationController


      def create
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

          end

        end
        require_user_logged_in!
        @job = Job.new(job_params)
        @job.user_id = Current.user.id
        # @job.location_id = job_params[:location_id]
        if @job.save!
          # @job_service.set_notification(@job[:id].to_i, @job[:user_id].to_i, params[:job][:notify].eql?("1"))
          puts "SUCCESSFULL"
          redirect_to @job
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @job = Job.find(params[:id])
        require_user_be_owner!
      end

      def update
        @job = Job.find(params[:id])
        if require_user_be_owner!
          if @job.update(job_params)
            # @job_service.edit_notification(@job[:id].to_i, @job[:user_id].to_i, params[:job][:notify].eql?("1"))
            redirect_to @job
          else
            render :edit, status: :unprocessable_entity
          end
        end
      end

      def destroy
        @job = Job.find(params[:id])
        if require_user_be_owner!
          @job.destroy
          redirect_to own_jobs_path, status: :see_other, notice: "Job successfully deleted."
        end
      end

      def find
        @jobs = Job.all.where("status = 'public'").first(100)
      end

      def parse_inputs
        @my_args = { "longitude" => params[:longitude].to_f, "latitude" => params[:latitude].to_f, "radius" => params[:radius].to_f, "time" => Time.parse(params[:time]), "limit" => params[:limit].to_i }
        # TODO: REMOVE 'first(100)'
        @result = FeedGenerator.initialize_feed(Job.all.where("status = 'public'").first(100).as_json, @my_args)
      end

      private

      def job_params
        params.require(:job).permit(:title, :description, :start_slot, :status, :user_id, :longitude, :latitude)
      end

      def mark_notifications_as_read
        if Current.user
          notifications_to_mark_as_read = @job.notifications_as_job.where(recipient: Current.user)
          notifications_to_mark_as_read.update_all(read_at: Time.zone.now)
        end
      end
    end
  end
end