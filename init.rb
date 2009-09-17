require 'digest/md5'
require 'cache_badger'

if !ActionController::Base.cache_store.is_a?(ActiveSupport::Cache::MemCacheStore)
  RAILS_DEFAULT_LOGGER.warn("You are using cache_badger with a store other than Memcached, which it isn't designed for. If your cache store doesn't work on the princple of fifo or take an expiry option you will get strange results.")
end

ActionController::Base.class_eval do

  helper CacheBadger::View

end
