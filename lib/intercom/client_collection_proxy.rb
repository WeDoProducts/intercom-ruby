require "intercom/utils"
require "ext/sliceable_hash"

module Intercom
  class ClientCollectionProxy

    attr_reader :resource_name, :finder_url, :resource_class

    def initialize(resource_name, finder_details: {}, client:)
      @resource_name  = resource_name
      @resource_class = Utils.constantize_resource_name(resource_name)
      @finder_url     = (finder_details[:url] || "/#{@resource_name}")
      @finder_params  = (finder_details[:params] || {})
      @client         = client
    end

    def each(&block)
      @next_page = nil
      loop do
        if @next_page
          begin
          response_hash = @client.get(@next_page, {})
          rescue Intercom::ServerError => e
            uri = URI.parse(@next_page)
            parsed_query = CGI.parse(uri.query)
            page = parsed_query["page"].first.to_i
            page += 1
            parsed_query["page"][0] = page.to_s
            uri.query = URI.encode_www_form(parsed_query)
            @next_page = uri.to_s
            retry
          end
        else
          response_hash = @client.get(@finder_url, @finder_params)
        end
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response_hash
        @next_page = extract_next_link(response_hash)
        deserialize_response_hash(response_hash, block)
        break if last_page?
      end

      self
    end

    def [](target_index)
      self.each_with_index do |item, index|
        return item if index == target_index
      end
      nil
    end

    def last_page?
      @next_page.nil?
    end

    include Enumerable

    protected

    def deserialize_response_hash(response_hash, block)
      top_level_type = response_hash.delete('type')
      if resource_name == 'subscriptions'
        top_level_entity_key = 'items'
      elsif resource_name == 'counts'
        top_level_entity_key = [@finder_params[:type].to_s, @finder_params[:count].to_s]
      else
        top_level_entity_key = Utils.entity_key_from_type(top_level_type)
      end
      response_hash.dig(*top_level_entity_key).each do |object_json|
        block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
    end

    def paging_info_present?(response_hash)
      !!(response_hash['pages'])
    end

    def extract_next_link(response_hash)
      return nil unless paging_info_present?(response_hash)
      paging_info = response_hash.delete('pages')
      paging_info = paging_info.delete('pages') if paging_info.key?('pages')
      paging_info['next']
    end
  end
end
