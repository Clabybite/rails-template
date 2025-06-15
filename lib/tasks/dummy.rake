# Rakefile or lib/tasks/dummy.rake
namespace :test do
  desc "Rebuild dummy Rails app for generator tests"
  task :dummy do
    require 'fileutils'
    dummy_path = File.expand_path("test/dummy", __dir__)
    FileUtils.rm_rf(dummy_path)
    system <<~SH
      rails new #{dummy_path} --skip-bundle --skip-git --skip-keeps --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-javascript --skip-hotwire --skip-jbuilder --skip-test
    SH
  end
end