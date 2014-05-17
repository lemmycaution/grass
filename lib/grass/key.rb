require 'active_model'
require 'active_support/core_ext/object/try'

module Grass
  
  ##
  # Key parses path info into template meta data
  
  class Key
    
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    
    KEY_REGEX = {
      locale: /\/([a-z]{2}|[a-z]{2}\-[A-Z]{2})\//,      
      dir: /\/(views\/layouts|views)\/|\/(scripts|stylesheets|images|fonts|statics)\/|\/(pages|texts)\//,      
      path: /\/([\w|\-|\/]+)/,
      ext: /\.(:?[a-z]{1,})/
    }
    FILE_REGEX = {
      # dir: /\/(views\/layouts|views)\/|\/assets\/(scripts|stylesheets|statics)\/|\/content\/(pages|texts)\//,
      dir: /\/(views\/layouts|views)\/|\/(scripts|stylesheets|images|fonts|statics)\/|\/(pages|texts)\//,            
      path: /\/([\w|\-|\/]+)/,
      locale: /\.([a-z]{2}|[a-z]{2}\-[A-Z]{2})\./,
      ext: /\.(:?[a-z]{1,})/
    }
    
    ATTR_TYPES = [:id, :dir, :path, :locale, :format, :handler, :filepath]
    
    FORMATS = {
      'texts'          => 'txt',
      'views'          => 'html',
      'views/layouts'  => 'html',
      'pages'          => 'html',
      'scripts'        => 'js',
      'stylesheets'    => 'css'
    }.freeze
    
    attr_accessor *ATTR_TYPES
    
    validates_presence_of :id,:dir,:path,:locale,:filepath
    
    # before_validation :parse
    
    def initialize attributes = {}
      super(attributes)
      parse()
    end
    
    def serializable_hash
      {id: self.id, dir: dir, path: path, locale: locale, format: format, handler: handler, filepath: filepath}
    end
    
    def to_s
      self.id
    end
    
    def fullpath
      @fullpath ||= @dir =~ /pages/ ? "/#{@locale}/#{@dir}/#{@path}" : "/#{@locale}/#{@dir}/#{@path}.#{@format}"
    end
    
    private
    
    ##
    # parses file or uri path to meta data
    
    def parse
      # we need one of them at least
      return nil if !@id.present? && !@filepath.present? 
      # get key from filepath if needs
      @id.nil? ? filepath_to_id : id_to_filepath
      # set default locale if null
      @locale ||= I18n.locale.to_s
      # cleanup blanks
      @handler = nil if @handler.blank?
      # set default format
      @format ||= FORMATS[@dir]
      # rebuild key
      @id = ["",@dir,@path].compact.join("/")
      # rebuild filepath
      dir = (is_asset? ? "assets/#{@dir}" : (is_content? ? "content/#{@dir}" : @dir))

      @filepath = Grass.app_root + ["",dir,@path].compact.join("/") + ["",@locale,@format,@handler].compact.join(".")      

    end
    
    ##
    # parsing based on uri path
    
    def id_to_filepath
      # parse attrs
      KEY_REGEX.each do |attr,regex|
        if match = @id.scan(regex).try(:flatten).try(:compact)
          if attr == :ext
            @format = match.shift
            @handler = match.join(".")
          else
            self.instance_variable_set "@#{attr}", match=match[0]
            @id.gsub!(/\/#{match}/,"") unless match.nil?
          end
        end
      end
    end
    
    ##
    # parsing based on file path
    
    def filepath_to_id
      @filepath = @filepath[@filepath.index(FILE_REGEX[:dir])..-1]
      FILE_REGEX.each do |attr,regex|
        if match = @filepath.scan(regex).try(:flatten).try(:compact)
          if attr == :ext
            @format = match.shift
            @handler = match.join(".")
          else
            self.instance_variable_set "@#{attr}", match=match[0]
            unless match.nil?
              attr == :locale ? @filepath.gsub!(/\.#{match}/,"") : @filepath.gsub!(/\/#{match}/,"")
            end
          end
        end
      end
    end
    
    
    def is_asset?
      @dir =~ /scripts|stylesheets|images|fonts|statics/
    end
    
    def is_content?
      @dir =~ /pages|texts/
    end
    

  end
end