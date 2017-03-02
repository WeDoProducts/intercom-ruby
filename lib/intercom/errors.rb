module Intercom

  # Base class exception from which all public Intercom exceptions will be derived
  class IntercomError < StandardError
    attr_reader :http_code, :application_error_code, :request_id

    def initialize(message, context = {})
      @message                = message
      @http_code              = context[:http_code]
      @application_error_code = context[:error_code]
      @request_id             = context[:request_id]
      super(formatted_message)
    end

    private

    def formatted_message
      "Message => '#{@message}', HTTP Code => #{@http_code}, Error Code => #{@application_error_code}, Request => #{@request_id}"
    end
  end

  # Raised when the credentials you provide don't match a valid account on Intercom.
  # Check that you have set <b>Intercom.app_id=</b> and <b>Intercom.app_api_key=</b> correctly.
  class AuthenticationError < IntercomError; end

  # Raised when something goes wrong on within the Intercom API service.
  class ServerError < IntercomError; end

  # Raised when we have bad gateway errors.
  class BadGatewayError < IntercomError; end

  # Raised when we experience a socket read timeout
  class ServiceUnavailableError < IntercomError; end

  # Raised when we experience socket connect timeout
  class ServiceConnectionError < IntercomError; end

  # Raised when requesting resources on behalf of a user that doesn't exist in your application on Intercom.
  class ResourceNotFound < IntercomError; end

  # Raised when the request has bad syntax
  class BadRequestError < IntercomError; end

  # Raised when you have exceeded the API rate limit
  class RateLimitExceeded < IntercomError; end

  # Raised when the request throws an error not accounted for
  class UnexpectedError < IntercomError; end

  # Raised when multiple users match the query (typically duplicate email addresses)
  class MultipleMatchingUsersError < IntercomError; end

  # Raised when a scroll already exists for the app
  class ScrollExistsError < IntercomError; end

  # Raised when you try to call a non-setter method that does not exist on an object
  class AttributeNotSetError < IntercomError; end

  # Raised when unexpected nil returned from server
  class HttpError < IntercomError; end

  #
  # Non-public errors (internal to the gem)
  #

  # Base class exception from which all private Intercom exceptions will be derived
  class IntercomInternalError < StandardError; end

  # Raised when we attempt to handle a method missing but are unsuccessful
  class NoMethodMissingHandler < IntercomInternalError; end

  class DeserializationError < IntercomInternalError; end
end
