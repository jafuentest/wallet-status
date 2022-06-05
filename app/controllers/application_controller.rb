class ApplicationController < ActionController::Base
  def not_found
    Rails.logger.info "Got not_found for #{request.method} #{request.path}"
    return head :not_found if request.xhr? || !request.format.html?

    render file: 'public/404.html'
  end
end
