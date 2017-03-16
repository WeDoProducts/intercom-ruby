require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'

module Intercom
  module Service
    class Segment < BaseService
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll

      def collection_class
        Intercom::Segment
      end
    end
  end
end
