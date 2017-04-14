require 'intercom/service/base_service'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'

module Intercom
  module Service
    class Counts < BaseService
      include ApiOperations::Find
      include ApiOperations::FindAll

      def collection_class
        Intercom::Count
      end

      def for_app
        find({})
      end

      def for_type(type:, count: nil)
        find_all(type: type, count: count)
      end
    end
  end
end
