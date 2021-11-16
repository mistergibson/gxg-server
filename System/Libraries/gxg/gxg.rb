# bootstrap.rb is a separate file so other external scripts can avail themselves of it.
require(::File.expand_path(::File.dirname(__FILE__) << "/gxg/bootstrap.rb"))
# Load base requirements: 
requirements = []
requirements.push({:requirement => "logger", :gem => nil})
requirements.push({:requirement => "fileutils", :gem => nil})
requirements.push({:requirement => "bigdecimal", :gem => nil})
requirements.push({:requirement => "singleton", :gem => nil})
requirements.push({:requirement => "set", :gem => nil})
requirements.push({:requirement => "csv", :gem => nil})
requirements.push({:requirement => "uri", :gem => nil})
requirements.push({:requirement => "socket", :gem => nil})
requirements.push({:requirement => "resolv", :gem => nil})
requirements.push({:requirement => "stringio", :gem => nil})
requirements.push({:requirement => "date", :gem => nil})
requirements.push({:requirement => "ffi", :gem => "ffi"})
requirements.push({:requirement => "base64", :gem => nil})
requirements.push({:requirement => "digest/md5", :gem => nil})
requirements.push({:requirement => "securerandom", :gem => nil})
requirements.push({:requirement => "json", :gem => nil})
requirements.push({:requirement => "chronic", :gem => "chronic"})
requirements.push({:requirement => "ffi-rzmq", :gem => "ffi-rzmq"})
requirements.push({:requirement => "ezmq", :gem => "ezmq"})
requirements.push({:requirement => "nokogiri", :gem => "nokogiri"})
requirements.push({:requirement => "rufus-scheduler", :gem => "rufus-scheduler"})
requirements.push({:requirement => "mimemagic", :gem => "mimemagic"})
requirements.push({:requirement => "mimemagic/overlay", :gem => "mimemagic"})
# consider adding facets later - esp. if file io needs extension
load_error = nil
requirements.to_enum.each do |entry|
	begin
    require entry[:requirement]
	rescue LoadError => the_error
		puts "Error: Missing Requirement\n" + the_error.to_s + "\n"
		if entry[:gem]
			puts "You need to install " + (entry[:gem]) + ", like so:\n"
			puts "sudo gem install '" + (entry[:gem]) + "'"
		else
			puts "You need to install " + (entry[:requirement]) + "."
		end
		load_error = true
    break
	end
end
unless load_error
  ## ---------------------------------------------------------------------------------------------------------------------
  # Various preliminary patches to dependencies:
  # ---------------------------------------------------------------------------------------------------------------------
  # Various preliminary patches to standard classes:
  # <none>
  # ---------------------------------------------------------------------------------------------------------------------
  # main module declaration:
  module GxG
    #
    def self.uuid_generate()
      ::SecureRandom::uuid.to_s
    end
    # LOG = $LOG
    LOG = ::Logger.new(STDOUT)
    #
  end
  #
  # ---------------------------------------------------------------------------------------------------------------------
  # Various data element classes:
  require File.expand_path("./gxg/gxg_elements.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  # Preliminary alternations to Kernel/Object class: Actor/Event support
  class Object
    # private methods
    private
    def this()
      self
    end
    #
    def pause(params={})
      #
    end
    # public methods
    public
    def is_any?(*args)
      result = false
      args.flatten.to_enum.each do |thing|
        if thing.class == Class
          if self.is_a?(thing)
            result = true
            break
          end
        end
      end
      result
    end
    #
    def alive?()
      # Why: adjusting the entire object space to dealing with possibilities introduced by Celluloid.
      true
    end
    #
    def actor?()
      false
    end
    #
    def handle_error(the_error={})
      if the_error[:error].is_a?(::Exception)
        log_error(the_error)
      end
    end
    #
    def serialize()
      if self.is_any?(::Array, ::Hash, ::Set, ::Struct)
        data = self.process do |entry, selector|
          entry.serialize()
        end
        begin
          ("structure:" + ::Marshal.dump(data).encode64())
        rescue Exception => the_error
          "marshal:BAgw"
        end
      else
        if self.is_a?(::String)
          if self.serialized?()
            self
          else
            ("marshal:" + ::Marshal.dump(self).encode64())
          end
        else
          # by default, or upon error, returns marshaled nil, must override to get other serialization
          begin
            ("marshal:" + ::Marshal.dump(self).encode64())
          rescue Exception => the_error
            "marshal:BAgw"
          end
        end
      end
    end
    #
  end
  # ---------------------------------------------------------------------------------------------------------------------
  # Units and support element classes:
  require File.expand_path("./gxg/gxg_units.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  # Event classes:
  require File.expand_path("./gxg/gxg_events.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------------------------------------
  # Additional alternations to Kernel/Object class: Data element class support, quota support functions
  module Kernel
    #
    #  alias :stock_enum_for :enum_for
    #  alias :stock_to_enum :to_enum
    #  def enum_for(method=:each,*args)
    #    GxG::Enumerator.new(self,method,*args)
    #  end
    #  alias :to_enum :enum_for
    #
    def slots_used(counted=[], options={})
      # returns how many heap slots are consumed by this *instance* (and elements) and its instance variables (and elements) all the way down.
      # General Research: see memprof for how much is consumed by a Module or Class or Method.
      # TODO: ::Kernel#slots_used : find the byte-size of a given :method and add it to slot_count initial value.
      unless counted.is_a?(Array)
        if counted.is_a?(Hash)
          options = counted
        end
        counted = []
      end
      # warning: assumes references to nil incur no RVALUE allocation.
      exclusions = [nil]
      if options[:exclude]
        unless options[:exclude].is_a?(Array)
          options[:exclude] = [(options[:exclude])]
        end
        exclusions = (options[:exclude] << nil)
      end
      slot_count = 0
      unless (counted.include?(self) || exclusions.include?(self))
        counted << self
        slot_count = 1
        if self.is_any?(::Array,::Hash,::Set,::Struct)
          self.search do |entry,selector,container|
            unless (counted.include?(entry) || exclusions.include?(entry))
              unless selector.is_a?(Numeric)
                slot_count += selector.slots_used(counted, {:exclude => exclusions})
              end
              slot_count += entry.slots_used(counted, {:exclude => exclusions})
            end
          end
        end
      end
      self.instance_variables.to_enum.each do |ivar|
        unless (counted.include?(ivar) || exclusions.include?(ivar))
          if ivar.is_any?(::Array,::Hash,::Set,::Struct)
            ivar.search do |entry,selector,container|
              unless (counted.include?(entry) || exclusions.include?(entry))
                unless selector.is_a?(Numeric)
                  slot_count += selector.slots_used(counted, {:exclude => exclusions})
                end
                slot_count += entry.slots_used(counted, {:exclude => exclusions})
              end
            end
          else
            slot_count += ivar.slots_used(counted, {:exclude => exclusions})
          end
        end
      end
      slot_count
    end
    #
    def content_size_used(counted=[], options={})
      # returns how many bytes are consumed by this *instance* (and elements) and its instance variables (and elements) all the way down.
      unless counted.is_a?(Array)
        if counted.is_a?(Hash)
          options = counted
        end
        counted = []
      end
      exclusions = [nil]
      if options[:exclude]
        unless options[:exclude].is_a?(Array)
          options[:exclude] = [(options[:exclude])]
        end
        exclusions = (options[:exclude] << nil)
      end
      count = 0
      unless (counted.include?(self) || exclusions.include?(self))
        counted << self
        if self.is_any?(::Array,::Hash,::Struct)
          self.search do |entry,selector,container|
            unless counted.include?(entry)
              unless selector.is_a?(Numeric)
                count += selector.content_size_used(counted, {:exclude => exclusions})
              end
              count += entry.content_size_used(counted, {:exclude => exclusions})
            end
          end
        else
          unless self.is_a?(::GxG::ByteArray)
            if self.respond_to?(:bytesize)
              count = self.bytesize
            else
              if self.respond_to?(:size)
                count = self.size
              else
                # TODO: cull the size of more exotic classes by class:
                count = 0
              end
            end
          end
        end
      end
      #
      self.instance_variables.to_enum.each do |ivar|
        # must decode from symbol to actual instance var
        ivar = self.instance_eval(ivar.to_s)
        unless (counted.include?(ivar) || exclusions.include?(ivar))
          if ivar.is_any?(::Array,::Hash,::Struct)
            ivar.search do |entry,selector,container|
              unless (counted.include?(entry) || exclusions.include?(entry))
                unless selector.is_a?(Numeric)
                  # Symbols and Strings in Hashes take up heap space, so lets count it.
                  count += selector.content_size_used(counted, {:exclude => exclusions})
                end
                count += entry.content_size_used(counted, {:exclude => exclusions})
              end
            end
          else
            unless (counted.include?(ivar) || exclusions.include?(ivar))
              count += ivar.content_size_used(counted, {:exclude => exclusions}).to_i
              # Subsequent references to this object will only incur an RVALUE slot count (me thinks)
              counted << ivar
            end
          end
        end
      end
      count
    end
    #
  end
  #
  class Object
    include Kernel
    #
    private
    #
    # logging hooks
    def log_unknown(message = nil, progname = nil, &block)
      # a.k.a 'unknown'
      if message.is_a?(::Hash)
        if message[:trace]
          message = (message[:trace].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
        else
          message = (message[:unknown].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
        end
      end
      ::GxG::LOG.unknown(message.to_s)
    end
    alias :log_trace :log_unknown
    def log_fatal(message = nil, progname = nil, &block)
      if message.is_a?(::Hash)
        if message[:error].is_a?(::Exception) || message[:fatal].is_a?(::Exception)
          if message[:error]
            message = (message[:error].to_s + "\n Parameters: #{message[:parameters].inspect.to_s},\n Backtrace: " + message[:error].backtrace.join("\n"))
          else
            message = (message[:fatal].to_s + "\n Parameters: #{message[:parameters].inspect.to_s},\n Backtrace: " + message[:fatal].backtrace.join("\n"))
          end
        else
          if message[:error]
            message = (message[:error].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
          else
            message = (message[:fatal].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
          end
        end
      end
      ::GxG::LOG.fatal(message.to_s)
    end
    def log_error(message = nil, progname = nil, &block)
      if message.is_a?(::Hash)
        if message[:error].is_a?(::Exception)
          message = (message[:error].to_s + "\n Parameters: #{message[:parameters].inspect.to_s},\n Backtrace: " + (message[:error].backtrace || []).join("\n"))
        else
          message = (message[:error].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
        end
      end
      ::GxG::LOG.error(message.to_s)
    end
    def log_warn(message = nil, progname = nil, &block)
      if message.is_a?(::Hash)
        if message[:warning]
          message = (message[:warning].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
        else
          message = (message[:warn].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
        end
      end
      ::GxG::LOG.warn(message.to_s)
    end
    alias :log_warning :log_warn
    def log_info(message = nil, progname = nil, &block)
      if message.is_a?(::Hash)
        message = (message[:info].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
      end
      ::GxG::LOG.info(message.to_s)
    end
    def log_debug(message = nil, progname = nil, &block)
      if message.is_a?(::Hash)
        if message[:dev] || message[:development]
          if message[:dev]
            message = (message[:dev].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
          else
            message = (message[:development].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
          end
        else
          message = (message[:debug].to_s + "\n Parameters: #{message[:parameters].inspect.to_s}")
        end
      end
      ::GxG::LOG.debug(message.to_s)
    end
    alias :log_dev :log_debug
    alias :log_development :log_debug
    #
    def bytes(*args)
      GxG::ByteArray::try_convert(args)
    end
    #
    def new_message(*args)
      if this.actor?()
        ::GxG::Events::Message.new({:sender => this().to_uri(), :subject => args[1], :body => args[0]})
      else
        ::GxG::Events::Message.new({:sender => this(), :subject => args[1], :body => args[0]})
      end
    end
    #
    public
    #
    def millisecond_latency(*args,&block)
      if block
        starting = Time.now.to_f
        result = block.call(*args)
        ending = Time.now.to_f
        # Results are approximate: does not include the time ruby needs to return from the call,
        # assign the result RVALUE, collect a time, convert it to a Float, and assign ending RVALUE..
        # However, it is pretty darn close.
        {:result => result, :milliseconds => (ending - starting)}
      else
        # If :milliseconds are nil then the block was not passed and since it never ran, there is no latency to count up.
        # Simply do a return_var[:milliseconds].to_f for auto-accumulators w/o post-call comparison.
        {:result => nil, :milliseconds => 0.0}
      end
      # Attribution : http://stackoverflow.com/questions/2289381/how-to-time-an-operation-in-milliseconds-in-ruby
    end
  end
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_augmented.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_entities.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_engine.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  # Alterations to Object class: GxG::Engine dependency - quota supports
  class Object
    public
    #
    def heap_used(options={})
      unless options.is_a?(Hash)
        options={}
      end
      (self.content_size_used(options) + (self.slots_used(options) * GxG::Engine::profile[:slot_size]))
    end
    #
  end
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_transcode.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_io.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_net.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_zmq.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/net_clients.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/net_tools.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_communications.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  # Set GxG Version and instantiate GxG::SYSTEM object:
  module GxG
    # setup constants, dispose of BOOTSTRAP data.
    VERSION = GxG::Version.new({:phase => :alpha, :revision => 39})
    VERSION.freeze
    #
    def self.shutdown()
      $Dispatcher.shutdown()
      ::GxG::Networking::ZMQ::zmq_default_context.terminate()
    end
  end
  # First attempt at object serialization/reconstitution:
  module GxG
    def self.reconstitute(raw_data="")
      # See: http://stackoverflow.com/questions/5758464/ruby-how-do-i-check-if-a-class-is-defined
      #
      if raw_data.is_a?(::String)
        if raw_data.serialized?()
          result = nil
          if raw_data.include?("marshal:")
            begin
              result = ::Marshal.load(raw_data[(8..-1)].decode64())
            rescue Exception
              # Question : what to do here.
            end
          else
            if raw_data.include?("structure:")
              data = ::Marshal.load(raw_data[(10..-1)].decode64())
              if data.is_any?(::Array, ::Hash, ::Set, ::Struct)
                result = data.process do |entry, selector|
                  if entry.is_a?(::String)
                    if entry.serialized?()
                      ::GxG::reconstitute(entry)
                      # entry.unserialize()
                    else
                      entry
                    end
                  else
                    entry
                  end
                end
              end
            else
              raise Exception, "unrecognized serialization format"
            end
          end
        else
          result = raw_data
        end
      else
        result = raw_data
      end
      result
      #
    end
    #
    # Generic toolbox of methods
    def self.passes_needed(size_used=0, container_limit=0)
      if size_used > 0 and container_limit > 0
        needed_raw = size_used.to_f / container_limit.to_f
        overhang = needed_raw - needed_raw.to_i.to_f
        needed_raw = needed_raw.to_i.to_f
        if overhang > 0.0
          needed_raw += 1.0
        end
        needed_raw.to_i
      else
        0
      end
    end
    #
    def self.apportioned_ranges(how_much_data=0, container_limit=0, original_offset=0)
      result = []
      the_count = ::GxG::passes_needed(how_much_data, container_limit)
      if the_count > 0
        offset = original_offset
        the_count.times do
          if (offset + (container_limit - 1)) <= (how_much_data - 1)
            end_point = (offset + (container_limit - 1))
          else
            end_point = (how_much_data - 1)
          end
          result << ((offset)..(end_point))
          offset = (end_point + 1)
        end
      end
      result
    end
    #
    def self.valid_uuid?(uuid=nil,strict=true)
      if uuid.is_any?(::String, ::Symbol)
        if strict == true
          pattern = /[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[4][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]/
        else
          pattern = /[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]/
        end
        if uuid.to_s.match(pattern)
          if uuid.to_s.size == 36
            true
          else
            false
          end
        else
          false
        end
      else
        false
      end
    end
    #
    def self.sql_statement?(the_string)
      # See: https://larrysteinle.com/2011/02/20/use-regular-expressions-to-detect-sql-code-injection/
      if /('(''|[^'])*')|(;)|(\\x08(ALTER|CREATE|DELETE|DROP|EXEC(UTE){0,1}|INSERT( +INTO){0,1}|MERGE|SELECT|UPDATE|UNION( +ALL){0,1})\\x08)/.match(the_string)
        true
      else
        false
      end
    end
    #
    def self.valid_domain_name?(the_string)
      if /^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$/.match(the_string)
        true
      else
        false
      end
    end
    #
  end
  # ---------------------------------------------------------------------------------------------------------------------
  require File.expand_path("./gxg/gxg_database.rb",File.dirname(__FILE__))
  require File.expand_path("./gxg/gxg_dbfs.rb",File.dirname(__FILE__))
  # ---------------------------------------------------------------------------------------------------------------------
  module GxG
      # Define Server directories, ensure directories are present
      gxg_root = $GXGROOT
      unless Dir.exist?(gxg_root)
          Dir.mkdir(gxg_root, 0775)
      end
      public_dir = File.expand_path("./Public",gxg_root)
      unless Dir.exist?(public_dir)
          Dir.mkdir(public_dir, 0775)
      end
      pub_theme_dir = "#{public_dir}/themes"
      unless Dir.exist?(pub_theme_dir)
          Dir.mkdir(pub_theme_dir, 0775)
      end
      pub_js_dir = "#{public_dir}/javascript"
      unless Dir.exist?(pub_js_dir)
          Dir.mkdir(pub_js_dir, 0775)
      end
      pub_image_dir = "#{public_dir}/images"
      unless Dir.exist?(pub_image_dir)
          Dir.mkdir(pub_image_dir, 0775)
      end
      pub_audio_dir = "#{public_dir}/audio"
      unless Dir.exist?(pub_audio_dir)
          Dir.mkdir(pub_audio_dir, 0775)
      end
      pub_video_dir = "#{public_dir}/video"
      unless Dir.exist?(pub_video_dir)
          Dir.mkdir(pub_video_dir, 0775)
      end
      #
      services_dir = File.expand_path("./Services",gxg_root)
      unless Dir.exist?(services_dir)
          Dir.mkdir(services_dir, 0775)
      end
      #
      app_dir = File.expand_path("./Applications",gxg_root)
      unless Dir.exist?(app_dir)
          Dir.mkdir(app_dir, 0775)
      end
      #
      # users_dir = File.expand_path("./Users",gxg_root)
      # unless Dir.exist?(users_dir)
      #     Dir.mkdir(users_dir, 0755)
      # end
      #
      system_dir = File.expand_path("./System",gxg_root)
      unless Dir.exist?(system_dir)
          Dir.mkdir(system_dir, 0755)
      end
      sys_config_dir = "#{system_dir}/Configuration"
      unless Dir.exist?(sys_config_dir)
          Dir.mkdir(sys_config_dir, 0755)
      end
      sys_db_dir = "#{system_dir}/Databases"
      unless Dir.exist?(sys_db_dir)
          Dir.mkdir(sys_db_dir, 0755)
      end
      sys_ext_dir = "#{system_dir}/Extensions"
      unless Dir.exist?(sys_ext_dir)
          Dir.mkdir(sys_ext_dir, 0755)
      end
      sys_gem_dir = "#{system_dir}/Gems"
      unless Dir.exist?(sys_gem_dir)
          Dir.mkdir(sys_gem_dir, 0755)
      end
      sys_lib_dir = "#{system_dir}/Libraries"
      unless Dir.exist?(sys_lib_dir)
          Dir.mkdir(sys_lib_dir, 0755)
      end
      tmp_dir = "#{system_dir}/Temporary"
      log_dir = "#{system_dir}/Logs"
      SERVER_PATHS = {:root => gxg_root, :system => system_dir, :services => services_dir, :temporary => tmp_dir, :logs => log_dir, :applications => app_dir, :users => nil, :public => public_dir,  :configuration => sys_config_dir, :themes => pub_theme_dir, :javascript => pub_js_dir, :images => pub_image_dir, :audio => pub_audio_dir, :video => pub_video_dir, :databases => sys_db_dir, :extensions => sys_ext_dir, :gems => sys_gem_dir, :libraries => sys_lib_dir}
  end
  #
  $Status = {:mode => :loading, :tasks => :undefined}
  $Dispatcher = ::GxG::Events::EventDispatcher.new(0.333)
  $Dispatcher.startup
end
#