module CacheBadger # :nodoc:
  module View # :nodoc:
    
    def cache_badger(options = {}, &block)
      options[:global]    = false if options[:global].nil?
      options[:plain_key] = false if options[:plain_key].nil?
      
      fragment = Fragment.new(controller)
      
      fragment.global    = options[:global]
      fragment.plain_key = options[:plain_key]

      yield fragment
      
      if ActionController::Base.cache_configured?
        RAILS_DEFAULT_LOGGER.warn("Your cache key is #{fragment.cache_key.size} characters long, it will be being truncated") if fragment.cache_key.size > 255
        Rails.cache.fetch(fragment.cache_key) do
          capture(&fragment.html)
        end
      else
        capture(&fragment.html)
      end
    end
    
    class Fragment
      
      attr_accessor :single_keys
      
      attr_accessor :key_pairs
      
      attr_accessor :plain_key

      attr_accessor :global
      
      def initialize(controller)
        @single_keys = []
        @key_pairs   = {}
        @plain_key   = false
        @global      = false
        @controller  = controller
      end
      
      def add_keys_if(test, &block)
        yield self if test
      end
      alias :add_if :add_keys_if

      def add_keys_unless(test, &block)
        yield self unless test
      end
      alias :add_unless :add_keys_unless
      
      def add_key(key, value = nil)
        if value.nil?
          @single_keys << key
        else
          @key_pairs[key] = value
        end
      end
      alias :add :add_key
      
      def cache_key
        unless @global == true
          @key_pairs[:controller] = @controller.controller_name
          @key_pairs[:action]     = @controller.action_name
        end
        
        unless @cache_key
          @cache_key  = "[#{@single_keys.join(":")}]"
          @cache_key += @key_pairs.collect { |key, value| "[#{key}:#{value.to_s}]" }.join
          @cache_key  = Digest::MD5.hexdigest(cache_key) if @plain_key != true
        end
        @cache_key
      end
      
      def html(&block)
        if block_given?
          @html = block
        else
          @html
        end
      end      
      
    end
    
  end
end
