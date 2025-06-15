class Admin::BaseController < ApplicationController
    before_action :admin_only

    private

    def admin_only
        unless current_user&.as_admin?
        redirect_to root_path, alert: "You are not authorized to access this page."
        end
    end
end