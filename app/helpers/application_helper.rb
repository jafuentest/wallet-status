module ApplicationHelper
  def bootstrap_alert
    return nil if flash.empty?

    flash_alert = flash.first
    render partial: 'alert', locals: { alert_type: flash_alert.first, message: flash_alert.last }
  end
end
