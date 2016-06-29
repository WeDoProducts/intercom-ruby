require 'intercom/service/base_service'
require 'intercom/api_operations/save'
require 'intercom/api_operations/bulk/submit'
require 'intercom/api_operations/find_all'

module Intercom
  module Service
    class Event < BaseService
      include ApiOperations::Save
      include ApiOperations::Bulk::Submit
      include ApiOperations::FindAll

      def collection_class
        Intercom::Event
      end
    end
  end
end
