class ScheduledJob < ApplicationRecord
    validates :name, :job_class, :cron, presence: true
    validate  :cron_must_be_valid
    validate  :job_class_must_exist
    before_validation :set_defaults, on: [:create]
  
    after_save :update_sidekiq_job
    after_destroy :remove_sidekiq_job
  
    private
  
    def update_sidekiq_job
      if active
        Sidekiq::Cron::Job.create(
          name: name,
          "class": job_class,
          cron: cron,
          queue: queue,
            active_job: job_class.safe_constantize < ApplicationJob,
        )
      else
        remove_sidekiq_job
      end
    end
  
    def remove_sidekiq_job
      job = Sidekiq::Cron::Job.find(name)
      job&.destroy
    end

    def cron_must_be_valid
        return if cron.blank? # Skip validation if the cron is blank (handled by presence validation)
        unless Fugit::Cron.parse(cron)
            errors.add(:cron, 'is not a valid cron expression')
        end
    end

    def job_class_must_exist
        klass = job_class.safe_constantize
        if klass.nil?
          errors.add(:job_class, "does not exist")
        elsif !(klass < ApplicationJob) && !(klass.included_modules.include?(Sidekiq::Worker))
            errors.add(:job_class, "must inherit from ApplicationJob or include Sidekiq::Worker")
        elsif !klass.instance_methods(false).include?(:perform)
            errors.add(:job_class, "must define a perform method")
        end
    end

    def set_defaults
        self.active ||= true
        self.queue ||= "default"
    end
      
  end