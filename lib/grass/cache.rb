module Grass
  module Cache
    
    module ClassMethods
      
      def read_cache cache_key
        JSON.load(Grass.cache.get(cache_key))
      end
      
      def generate_cachekey keyid, data
        Digest::MD5.hexdigest("#{keyid}_#{data}")      
      end
      
    end
    
    def self.included(base)
      base.extend ClassMethods
      base.send :after_destroy, :clear_cache
    end
    
    def commit! result = nil
      clear_cache if precompile?
      super(result)
      set_cache if precompile?
      self
    end

    def cache!
      set_cache
    end

    def precompile?
      self.binary.nil? && self.type == "script" || self.type == "style"
    end
    
    module_function
    
    def cache
      Grass.cache
    end
    
    def set_cache
      cache.set self.class.generate_cachekey(self.keyid,self.data), JSON.dump([self.mime_type, self.read].flatten)
    end
    
    def clear_cache
      cache.delete self.class.generate_cachekey(self.keyid,self.data) rescue nil
    end
    
  end
end