class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :authenticate_api_request

  private

  def authenticate_api_request
    authenticate_or_request_with_http_basic do |username, _password|
      if username.start_with?("astra_")
        api_key = ApiKey.find_by(api_secret: username)
        if api_key
          @api_key = api_key
          return true
        end
      end
      head :unauthorized
    end
  end
end
