require 'intercom/client_collection_proxy'

module Intercom
  class ClientScrollCollectionProxy < Intercom::ClientCollectionProxy

    attr_accessor :finder_params

    def each(&block)
      loop do
        begin
          response_hash = @client.get(@finder_url, @finder_params)
          unless response_hash
            raise Intercom::HttpError.new('Http Error - No response entity returned')
          end
          break unless deserialize_response_hash(response_hash, block)
          @finder_params[:scroll_param] ||= extract_next_link(response_hash)
        rescue Intercom::ServerError => e
          puts "Caught server error"
          retry
        rescue Intercom::HttpError => e
          if @finder_params[:scroll_param]
            puts "Caught HTTP error"
            retry
          end
        end
      end
      self
    end

    protected

    def deserialize_response_hash(response_hash, block)
      top_level_type = response_hash.delete('type')
      if resource_name == 'subscriptions'
        top_level_entity_key = 'items'
      else
        top_level_entity_key = Utils.entity_key_from_type(top_level_type)
      end

      return false if response_hash[top_level_entity_key].size.zero?

      response_hash[top_level_entity_key].each do |object_json|
        block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
      true
    end

    def extract_next_link(response_hash)
      response_hash["scroll_param"]
    end
  end
end
