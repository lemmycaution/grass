module Grass
  module Cache
    
    DATA_CACHE_KEYS = %i(language_info country_info params http_host request_path)
    
    module ClassMethods
      
      def read_cache cache_key
        JSON.load(Grass.cache.get(cache_key))
      end
      
      def generate_cachekey key_fullpath, data
        Digest::MD5.hexdigest("#{key_fullpath}_#{data.select{|k,v| DATA_CACHE_KEYS.include?(k)}}")      
      end
      
    end
    
    def self.included(base)
      base.extend ClassMethods
      base.send :after_destroy, :clear_cache
    end
    
    def commit! result = nil
      # clear_cache if precompile?
      super(result)
      set_cache if precompile?
      self
    end

    def cache!
      set_cache
    end

    def precompile?
      self.binary.nil? && (self.type == "script" || self.type == "stylesheet")
    end
    
    module_function
    
    def set_cache
      Grass.cache.set(
      self.class.generate_cachekey(self.key.fullpath,self.data), 
      JSON.dump([self.mime_type, self.read].flatten)
      )
    end
    
    def clear_cache
      Grass.cache.delete self.class.generate_cachekey(self.key.fullpath,self.data) rescue nil
    end
    
  end
end