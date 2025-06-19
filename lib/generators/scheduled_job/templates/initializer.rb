if Rails.env.production? || Rails.env.development?
  require 'sidekiq'
  require 'sidekiq-cron'

  ActiveSupport.on_load(:after_initialize) do
    begin
      if ActiveRecord::Base.connection.data_source_exists?('scheduled_jobs')
        ScheduledJob.where(active: true).find_each do |job|
          Sidekiq::Cron::Job.create(
            name: job.name,
            class: job.job_class,
            cron: job.cron,
            queue: job.queue,
            active_job: job.job_class.safe_constantize < ApplicationJob,
          )
        end
      else
        Rails.logger.info "[sidekiq-cron] no scheduled_jobs table – skipping load"
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
      Rails.logger.info "[sidekiq-cron] DB not ready (#{e.message}) – skipping scheduled cron load"
    end
  end
end
