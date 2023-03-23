class UserController < ApplicationController
  before_action :require_user_logged_in

  def index
    @user = Current.user
    @user.update(view_count: @user.view_count + 1)
    # @jobs = @user.jobs.includes(:rich_text_body).order(created_at: :desc)
    @jobs = @user.jobs.order(created_at: :desc)
    @total_job_views = 0

    @jobs.each do |job|
      @total_job_views += job.view_count
    end
  end

  def settings
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    require_user_logged_in
    if @user.update(user_params)
      redirect_to @user, notice: "Updated profile"
    else
      render :index, status: :unprocessable_entity, alert: "Could not save changes"
    end
  end

  def preferences
    @user = Current.user
    if @user.preferences.nil?
      @user.create_preferences
      @user.save
    end

    @preferences = Current.user.preferences
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys
  end

  def own_jobs
    # @jobs = @user.jobs.includes(:rich_text_body).order(created_at: :desc)
    @jobs = Current.user.jobs.order(created_at: :desc)
  end

  def own_applications
    @applications = Application.includes(:user).all.where("user_id = #{Current.user.id}").order("updated_at DESC")
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :degree, :date_of_birth, :country_code, :city, :postal_code, :address, :twitter_url, :facebook_url, :linkedin_url, :instagram_url)
  end

  # PHONE
  # DEGREE

end

