class ApplicationController < ActionController::Base
  rescue_from ActionController::InvalidAuthenticityToken, with: :redirect_to_referer_or_root
  add_flash_types :success, :error, :warning

  def not_found
    Rails.logger.info "Got not_found for #{request.method} #{request.path}"
    return head :not_found if request.xhr? || !request.format.html?

    render file: 'public/404.html'
  end

  private

  def current_action
    matched_route = Rails.application.routes.recognize_path(request.env['PATH_INFO'])
    matched_route[:action]
  end

  def redirect_to_referer_or_root
    return not_found if current_action == 'not_found'

    flash[:notice] = 'Please try again.'
    redirect_to request.referer.presence || root_path
  end
end
