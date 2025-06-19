class Admin::ScheduledJobsController < Admin::BaseController
    before_action :set_model, only: [:show,:edit, :update, :destroy]
  
    def index
      @scheduled_jobs = ScheduledJob.all
    end
  
    def new
      @scheduled_job = ScheduledJob.new(active: true, queue: "default", cron: "* * * * *")
      @job_classes = available_job_classes
    end
  
    def create
      @scheduled_job = ScheduledJob.new(model_params)
      if @scheduled_job.save
        redirect_to admin_scheduled_jobs_path, notice: "Job created successfully."
      else
        @job_classes = available_job_classes
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit; end
  
    def update
      if @scheduled_job.update(model_params)
        redirect_to admin_scheduled_jobs_path, notice: "Job updated successfully."
      else
        render :edit
      end
    end
  
    def destroy
      @scheduled_job.destroy
      redirect_to admin_scheduled_jobs_path, notice: "Job deleted successfully."
    end
  
    private
  
    def set_model
      @scheduled_job = ScheduledJob.find(params[:id])
      @job_classes = available_job_classes
    end
  
    def model_params
      params.require(:scheduled_job).permit(:name, :job_class, :cron, :queue, :active)
    end

    def available_job_classes
      Rails.application.eager_load! unless Rails.application.config.eager_load
      worker_classes = ObjectSpace.each_object(Class).select do |k|
        (k < ApplicationJob || k.included_modules.include?(Sidekiq::Worker)) &&
          k.name.present? &&
          k.name.start_with?("::").!
      end

      # Remove duplicates and wrappers (e.g., ApplicationJob, ApplicationWorker)
      worker_classes.map(&:name).uniq.reject { |name|
        name == "ApplicationJob" || name == "ApplicationWorker" || name.include?("::")
      }.sort
    end
  end