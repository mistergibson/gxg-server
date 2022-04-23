#!/usr/bin/env jruby
if ARGV.include?("--quiet")
  STDIN.reopen("/dev/null", "r")
  STDOUT.reopen("/dev/null", "w")
  STDERR.reopen("/dev/null", "w")
end
require 'rubygems'
require 'gxg-framework'
# ### Define Directory Layout for Server
::GxG::SYSTEM.gxg_root = File.expand_path("../",File.dirname(__FILE__))
module GxG
  # Define Server directories, ensure directories are present
  SYSTEM_PATHS = ::GxG::SYSTEM.server_paths()
end
::GxG::SYSTEM_PATHS.values.each do |a_path|
  if a_path
    unless Dir.exist?(a_path)
      begin
        FileUtils.mkpath(a_path)
      rescue Exception => error
        log_error({:error => error, :parameters => a_path})
      end
    end
  end
end
# ### Mount Databases by role
if File.exists?("#{GxG::SYSTEM_PATHS[:configuration]}/databases.json")
    handle = File.open("#{GxG::SYSTEM_PATHS[:configuration]}/databases.json", "rb")
    db_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
    handle.close
    # ### Set DB Roles, and other details
    ::GxG::DB[:roles] = {}
    if db_config[:databases].is_a?(::Array)
      #
      mounted = []
      db_config[:databases].each do |entry|
        entry[:roles].each do |the_role|
          if the_role.downcase == "users"
            #
            if ::URI::parse(entry[:url]).scheme.downcase == "ldap"
              # TODO: ExternalAuthority
              mounted << {:url => entry[:url].to_s, :db => nil, :roles => [:user]}
            else
              if ::URI::parse(entry[:url]).scheme.downcase == "sqlite"
                  if ::URI::parse(entry[:url]).hostname.to_s[0] == "/" || ::URI::parse(entry[:url]).path.to_s[0] == "/"
                      # absolute path
                      the_db_url = entry[:url]
                  else
                      # relative path
                      the_db_url = "sqlite://#{GxG::SYSTEM_PATHS[:databases]}/#{::URI::parse(entry[:url]).hostname}"
                  end
              else
                  the_db_url = entry[:url]
              end
              the_db = ::GxG::Database::connect(the_db_url)
              if the_db
                the_db.clear_all_element_locks
                the_db.empty_trash
                ::GxG::DB[:authority] = the_db
                ::GxG::DB[:roles][:users] = ::GxG::DB[:authority]
                mounted << {:url => entry[:url].to_s, :db => the_db, :roles => [:users]}
                break
              end
            end
            #
          end
        end
        if ::GxG::DB[:authority].is_any?(::GxG::Database::Database, ::GxG::Database::ExternalAuthority)
          break
        end
      end
      #
      if ::GxG::DB[:authority].is_any?(::GxG::Database::Database, ::GxG::Database::ExternalAuthority)
        db_config[:databases].each do |entry|
          log_info "Mounting or creating a database ..."
          if (mounted.map {|item| item[:url]}).include?(entry[:url].to_s)
            # Flesh out other roles : {:url => entry[:url].to_s, :db => the_db, :roles => [:user]}            
            mounted.each do |the_mount|
              #
              if entry[:url] == the_mount[:url]
                entry[:roles].each do |the_role|
                  unless the_mount[:roles].include?(the_role)
                    ::GxG::DB[:roles][(the_role.to_sym)] = the_mount[:db]
                    the_mount[:roles] << the_role.to_sym
                  end
                end
              end
              #
            end
          else
            # Mount fresh
            if ::URI::parse(entry[:url]).scheme.downcase == "sqlite"
                if ::URI::parse(entry[:url]).hostname.to_s[0] == "/" || ::URI::parse(entry[:url]).path.to_s[0] == "/"
                    # absolute path
                    the_db_url = entry[:url]
                else
                    # relative path
                    the_db_url = "sqlite://#{GxG::SYSTEM_PATHS[:databases]}/#{::URI::parse(entry[:url]).hostname}"
                end
            else
                the_db_url = entry[:url]
            end
            the_db = ::GxG::Database::connect(the_db_url, {:authority => ::GxG::DB[:authority]})
            if the_db
              # house cleaning:
              the_db.clear_all_element_locks
              the_db.empty_trash
              mounted_roles = []              
              entry[:roles].each do |the_role|
                unless ::GxG::DB[:roles][(the_role.to_sym)]
                  ::GxG::DB[:roles][(the_role.to_sym)] = the_db
                  mounted_roles << the_role.to_sym
                end
              end
              mounted << {:url => entry[:url].to_s, :db => the_db, :roles => mounted_roles}
            end
            #
          end
        end
      else
        # Error - no authority db found, unable to proceed.
        log_error "No Authority Database Found : Unable to proceed."
        exit 1
      end
      #
      unless ::GxG::DB[:roles][:formats].is_a?(::GxG::Database::Database)
        # Error - no format db found, unable to proceed.
        log_error "No Format Database Found : Unable to proceed."
        exit 1
      end
      #
    end
    # Set Administrator/Members credential for system use.
    ::GxG::DB[:administrator] = ::GxG::DB[:authority][:system_credentials][:administrator]
    ::GxG::DB[:administrators] = ::GxG::DB[:authority][:system_credentials][:administrators]
    ::GxG::DB[:developers] = ::GxG::DB[:authority][:system_credentials][:developers]
    ::GxG::DB[:designers] = ::GxG::DB[:authority][:system_credentials][:designers]
    ::GxG::DB[:users] = ::GxG::DB[:authority][:system_credentials][:users]
else
    log_warn "No Database Configuration found: run setup.rb from the shell."
end
# ### Populate the Mandatory VFS with GxG::SYSTEM_PATHS
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:system]}), "/System")
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:services]}), "/Services")
# User-Agent code goes in '/Applications'. Rename to '/Agents' ??
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:applications]}), "/Applications")
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:temporary]}), "/Temporary")
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:logs]}), "/Logs")
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:public]}), "/Public")
# Populate Optional VFS mount points
if GxG::valid_uuid?(GxG::DB[:administrator])
    if File.exists?("#{GxG::SYSTEM_PATHS[:configuration]}/mounts.json")
        handle = File.open("#{GxG::SYSTEM_PATHS[:configuration]}/mounts.json", "rb")
        mount_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
        handle.close
        #
        volume = nil
        mount_config[:mount_points].each do |entry|
            if entry[:db_role]
                the_db = ::GxG::DB[:roles][(entry[:db_role].to_sym)]
                if the_db
                  volume = ::GxG::Storage::Volume.new({:database => the_db, :credential => GxG::DB[:administrator]})
                end
            end
            if entry[:file_system]
              if ["./", ".."].include?(entry[:file_system][0..1])
                # Relative Path - to GXGROOT
                fs_path = File.expand_path(entry[:file_system],::GxG::SYSTEM.gxg_root())
              else
                # Absolute Path
                fs_path = entry[:file_system]
              end
              unless Dir.exist?(fs_path)
                  FileUtils.mkdir_p(fs_path)
              end
              if entry[:path] == "/Users"
                ::GxG::SYSTEM_PATHS[:users] = fs_path
                unless Dir.exist?(fs_path + "/Shared")
                    FileUtils.mkdir_p((fs_path + "/Shared"))
                end
              else
                ::GxG::SYSTEM_PATHS[(File.basename(entry[:path]).downcase.to_sym)] = fs_path 
              end
              volume = ::GxG::Storage::Volume.new({:directory => fs_path})
            end
            if volume
              GxG::VFS.mount(volume, entry[:path])
              volume = nil
            end
        end
    else
        log_warn "No VFS Optional Configuration found: run setup.rb from the shell."
    end
end
# ### Services Framework
module GxG
  SERVICES = {}
  module Services
    # ### Service Management
    def self.start_order()
      # Calculate service startup order based upon interdepenedencies
      # Review : Research a REAL dep tree calculator - See: https://stackoverflow.com/questions/21108109/how-do-i-find-out-all-the-dependencies-of-a-gem
      deps = {}
      ::GxG::SERVICES.each_pair do |moniker, service|
        unless moniker == :core
          unless deps[(moniker)]
            deps[(moniker)] = 0
          end
          service.required_services().each do |the_dep|
            if deps[(the_dep.to_sym)]
              deps[(the_dep.to_sym)] -= 1
            else
              deps[(the_dep.to_sym)] = 0
            end
          end
        end
      end
      boot_queue = []
      (deps.sort_by {|key,value| value}).to_h.keys.each do |the_service_moniker|
        ::GxG::SERVICES[(the_service_moniker)].required_services.each do |moniker|
          unless boot_queue.include?(moniker)
            boot_queue << moniker
          end
        end
        unless boot_queue.include?(the_service_moniker)
          boot_queue << the_service_moniker
        end
      end
      #
      boot_queue
    end
    #
    def self.stop_order()
      ::GxG::Services::start_order().reverse!
    end
    #
    def self.start_service(moniker=nil)
      if moniker.is_a?(::Symbol)
        if ::GxG::SERVICES[(moniker)]
          ::GxG::SERVICES[(moniker)].start
        end
      end
    end
    #
    def self.stop_service(moniker=nil)
      if moniker.is_a?(::Symbol)
        if ::GxG::SERVICES[(moniker)]
          ::GxG::SERVICES[(moniker)].stop
        end
      end
    end
    #
    def self.install_service(moniker=nil)
      if moniker.is_a?(::Symbol)
        configuration = ::GxG::SERVICES[:core].configuration
        unless configuration[:available].is_a?(::Array)
          configuration[:available] = []
        end
        unless configuration[:available].include?(moniker.to_s)
          configuration[:available] << moniker.to_s
        end
        ::GxG::SERVICES[:core].save_configuration
        #
        true
      else
        false
      end
    end
    #
    def self.service_available?(moniker=nil)
      if moniker.is_a?(::Symbol)
        configuration = ::GxG::SERVICES[:core].configuration
        if configuration[:available].is_a?(::Array)
          if configuration[:available].include?(moniker.to_s)
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
    def self.enable_service(moniker=nil)
      if moniker.is_a?(::Symbol)
        configuration = ::GxG::SERVICES[:core].configuration
        unless configuration[:disabled].is_a?(::Array)
          configuration[:disabled] = []
        end
        unless configuration[:enabled].is_a?(::Array)
          configuration[:enabled] = []
        end
        if configuration[:disabled].include?(moniker.to_s)
          configuration[:disabled].delete_at(configuration[:enabled].find_index(moniker.to_s))
        end
        unless configuration[:enabled].include?(moniker.to_s)
          configuration[:enabled] << moniker.to_s
        end
        ::GxG::SERVICES[:core].save_configuration
        #
        true
      else
        false
      end
    end
    #
    def self.disable_service(moniker=nil)
      if moniker.is_a?(::Symbol)
        configuration = ::GxG::SERVICES[:core].configuration
        unless configuration[:disabled].is_a?(::Array)
          configuration[:disabled] = []
        end
        unless configuration[:enabled].is_a?(::Array)
          configuration[:enabled] = []
        end
        if configuration[:enabled].include?(moniker.to_s)
          configuration[:enabled].delete_at(configuration[:enabled].find_index(moniker.to_s))
        end
        unless configuration[:disabled].include?(moniker.to_s)
          configuration[:disabled] << moniker.to_s
        end
        ::GxG::SERVICES[:core].save_configuration
        #
        true
      else
        false
      end
    end
    #
    def self.register_service(moniker=:unspecified, service_harness=nil)
      if moniker
        unless moniker == :unspecified
          if service_harness.is_a?(GxG::Services::Service)
            GxG::SERVICES[(moniker)] = service_harness
          end
        end
      end
    end
    # ### Service Class Definition
    class Service
      # Class-level toolbox:
      # Instance toolbox:
      def initialize(moniker=:unspecified, options={:event_interval => 0.333})
        if moniker.is_a?(::Symbol)
          if moniker == :unspecified || (::GxG::SERVICES[:core] && moniker == :core)
            raise Exception, "You MUST provide a unique, specific Symbol as your service moniker. This becomes the system-wide service name other services will need provided."
          else
            # Service Initialization code
            @provides = moniker
            @requirements = [:core]
            @thread_safety = ::Mutex.new
            @heap = {}
            @status = :stopped
            @state = nil
            @configuration = {}
            @dispatcher = ::GxG::Events::EventDispatcher.new((options[:event_interval] || 0.333))
            @interface = {}
            #
            self.load_configuration
            #
            self.on(:interface, {:description => "Available Commands", :usage => "{ :interface => nil }", :public => true}) do
              self.interface()
            end
            #
            ::GxG::Services::register_service(moniker, self)
            #
          end
        else
          raise Exception, "You MUST provide a unique service name as a Symbol for your service moniker."
        end
        self
      end
      #
      def inspect()
        "<Service #{@provides.inspect}>"
      end
      # ### FS & VFS
      def vfs_root()
        if @provides == :core
          "/Services"
        else
          "/Services/#{@provides.to_s}"
        end
      end
      #
      def fs_root()
        ::File.expand_path("#{::GxG::SYSTEM.gxg_root()}/#{self.vfs_root()}")
      end
      # ### Service Management
      def provides()
        @provides
      end
      #
      def required_services()
        @requirements.clone
      end
      #
      def require_service(moniker=:unspecified)
        if moniker.is_a?(::Symbol)
          unless moniker == :unspecified
            unless @requirements.include?(moniker)
              @requirements << moniker
            end
          end
        end
      end
      # ### Configuration Management
      def configuration()
        @configuration
      end
      #
      def save_configuration(options={})
        result = false
        config_path = ::File.expand_path(::GxG::SYSTEM_PATHS[:configuration] + "/" + "#{@provides.to_s}.json")
        if File.exists?(config_path)
          File.delete(config_path)
        end
        begin
          handle = File.open(config_path, "w+b", 0664)
          handle.write(::JSON::pretty_generate(@configuration))
          handle.close
          result = true
        rescue Exception => the_error
          log_warn("Failed to save configuration for #{@provides.inspect} --> #{the_error.to_s}")
        end
        result
      end
      #
      def load_configuration(options={})
        result = false
        config_path = ::File.expand_path(::GxG::SYSTEM_PATHS[:configuration] + "/" + "#{@provides.to_s}.json")
        if File.exists?(config_path)
          handle = File.open(config_path, "rb", 0664)
          begin
            @configuration =::JSON::parse(handle.read(), {:symbolize_names => true})
            result = true
          rescue Exception => the_error
            log_warn("Failed to load configuration for #{@provides.inspect} --> #{the_error.to_s}")
          end
          handle.close
          #
          if result == true
            if ::GxG::valid_uuid?(@configuration[:state_uuid])
              unless @state.is_a?(::GxG::Database::PersistedHash)
                @state = ::GxG::DB[:roles][:data].retrieve_by_uuid(@configuration[:state_uuid].to_s.to_sym, ::GxG::DB[:administrator])
                if @state.is_a?(::GxG::Database::PersistedHash)
                  @state.get_reservation
                else
                  # This means the db was blown out and this must be reconstructed.
                  @state = ::GxG::DB[:roles][:data].try_persist({}, ::GxG::DB[:administrator])
                  @state.get_reservation
                  @state.set_title("#{@provides.to_s} State Data")
                  @state.save
                  @configuration[:state_uuid] = @state.uuid.to_s
                end
              end
            else
              orphaned_state_record = GxG::DB[:roles][:data].uuid_list(GxG::DB[:administrator],{:title => "#{@provides.to_s} State Data"}).first
              if orphaned_state_record
                @state = ::GxG::DB[:roles][:data].retrieve_by_uuid((orphaned_state_record[:uuid]),::GxG::DB[:administrator])
              end
              unless @state.is_a?(::GxG::Database::PersistedHash)
                @state = ::GxG::DB[:roles][:data].try_persist({}, ::GxG::DB[:administrator])
                @state.get_reservation
                @state.set_title("#{@provides.to_s} State Data")
                @state.save
              end
              @configuration[:state_uuid] = @state.uuid.to_s
            end
          end
        else
          if @state.is_a?(::GxG::Database::PersistedHash)
            unless ::GxG::valid_uuid?(@configuration[:state_uuid])
              @configuration[:state_uuid] = @state.uuid.to_s
            end
          else
            if ::GxG::valid_uuid?(@configuration[:state_uuid])
              @state = ::GxG::DB[:roles][:data].retrieve_by_uuid(@configuration[:state_uuid].to_s.to_sym, ::GxG::DB[:administrator])
              @state.get_reservation
            else
              orphaned_state_record = GxG::DB[:roles][:data].uuid_list(GxG::DB[:administrator],{:title => "#{@provides.to_s} State Data"}).first
              if orphaned_state_record
                @state = ::GxG::DB[:roles][:data].retrieve_by_uuid((orphaned_state_record[:uuid]),::GxG::DB[:administrator])
              end
              unless @state.is_a?(::GxG::Database::PersistedHash)
                @state = ::GxG::DB[:roles][:data].try_persist({}, ::GxG::DB[:administrator])
                @state.get_reservation
                @state.set_title("#{@provides.to_s} State Data")
                @state.save
              end
              @configuration[:state_uuid] = @state.uuid.to_s
            end
          end
          self.save_configuration
          result = true
        end
        result
      end
      # ### Heap & State Data
      def keys()
        @thread_safety.synchronize { @heap.keys }
      end
      #
      def [](key=nil)
        if key.is_any?(::String, ::Symbol)
          @thread_safety.synchronize { @heap[(key)] }
        else
          nil
        end
      end
      #
      def []=(key=nil,value=nil)
        if key.is_any?(::String, ::Symbol)
          @thread_safety.synchronize { @heap[(key)] = value }
        else
          nil
        end
      end
      #
      def delete(key=nil)
        if key.is_any?(::String, ::Symbol)
          @thread_safety.synchronize { @heap.delete(key) }
        else
          nil
        end
      end
      #
      def state_keys()
        @state.keys()
      end
      #
      def state_get(state_key=nil)
        result = nil
        if state_key.is_a?(::Symbol)
          if @state.is_a?(::GxG::Database::PersistedHash)
            result = @state[(state_key)]
          end
        end
        result
      end
      #
      def state_set(state_key=nil, state_value=nil)
        if state_key.is_a?(::Symbol)
          if @state.is_a?(::GxG::Database::PersistedHash)
            @state[(state_key)] = state_value
            @state.save
          end
        end
      end
      #
      def state_delete(key)
        result = nil
        if state_key.is_a?(::Symbol)
          if @state.is_a?(::GxG::Database::PersistedHash)
            result = @state.delete(state_key)
          end
        end
        result
      end
      # ### Activity and Status Management
      def is_running?()
        @status == :running || @status == :paused
      end
      #
      def status()
        @status
      end
      #
      def start(options={:timeout => 30000.0})
        # start entire service, load configuration
        @status = :starting
        if self.load_configuration() == true
          timeout = Time.now.to_f + (options[:timeout] || 30000.0)
          all_loaded = false
          #
          if @provides == :core
            all_loaded = true
          else
            # wait until all requirements load until timeout
            requirement_count = @requirements.size
            while (Time.now.to_f < timeout) do
              started_count = 0
              @requirements.each do |moniker|
                if ::GxG::SERVICES[(moniker)].is_running? == true
                  started_count += 1
                end
              end
              if requirement_count == started_count
                all_loaded = true
                break
              else
                sleep 1.0
              end
            end
            unless all_loaded == true
              log_warn("Aborted service startup for #{@provides.inspect} because other required services did not start in time.")
            end
          end
          #
          if all_loaded == true
            if self.respond_to_event?(:before_start)
              self.call_event({:before_start => self}, ::GxG::DB[:administrator])
            end
            # start event dispatcher
            @dispatcher.startup
            @status = :running
            if self.respond_to_event?(:at_start)
              self.call_event({:at_start => self}, ::GxG::DB[:administrator])
            end
            if self.respond_to_event?(:after_start)
              self.call_event({:after_start => self}, ::GxG::DB[:administrator])
            end
            true
          else
            @status = :stopped
            false
          end
          #
        else
          @status = :stopped
          false
        end
        #
      end
      #
      def stop(options={})
        # stop entire service
        if self.respond_to_event?(:before_stop)
          self.call_event({:before_stop => self}, ::GxG::DB[:administrator])
        end
        @status = :stopping
        #
        if self.respond_to_event?(:at_stop)
          self.call_event({:at_stop => self}, ::GxG::DB[:administrator])
        end
        @dispatcher.shutdown
        #
        @status = :stopped
        if self.respond_to_event?(:after_stop)
          self.call_event({:after_stop => self}, ::GxG::DB[:administrator])
        end
        true
      end
      #
      def restart(options={})
        # restart entire service, reloading configuration
        if self.respond_to_event?(:before_restart)
          self.call_event({:before_restart => self}, ::GxG::DB[:administrator])
        end
        if self.stop(options) == true
          self.start(options)
          if self.respond_to_event?(:at_restart)
            self.call_event({:at_restart => self}, ::GxG::DB[:administrator])
          end
          if self.respond_to_event?(:after_restart)
            self.call_event({:after_restart => self}, ::GxG::DB[:administrator])
          end
          true
        else
          false
        end
        #
      end
      #
      def pause(options={})
        # pause dispatcher
        if self.respond_to_event?(:before_pause)
          self.call_event({:before_pause => self}, ::GxG::DB[:administrator])
        end
        @dispatcher.shutdown
        @status = :paused
        if self.respond_to_event?(:at_pause)
          self.call_event({:at_pause => self}, ::GxG::DB[:administrator])
        end
        if self.respond_to_event?(:after_pause)
          self.call_event({:after_pause => self}, ::GxG::DB[:administrator])
        end
        true
      end
      #
      def resume(options={})
        # resume dispatcher
        if self.respond_to_event?(:before_resume)
          self.call_event({:before_resume => self}, ::GxG::DB[:administrator])
        end
        @dispatcher.startup
        @status = :running
        if self.respond_to_event?(:at_resume)
          self.call_event({:at_resume => self}, ::GxG::DB[:administrator])
        end
        if self.respond_to_event?(:after_resume)
          self.call_event({:after_resume => self}, ::GxG::DB[:administrator])
        end
        true
      end
      # ### Command Interface:
      def dispatcher()
        @dispatcher
      end
      #
      def on(the_event, options={}, &block)
        unless the_event.is_a?(::Symbol)
          raise ArgumentError, "You must specify an event listener with a unique Symbol."
        end
        unless block.respond_to?(:call)
          raise ArgumentError, "You must provide an event code block to execute."
        end
        unless options[:description]
          options[:description] = "Event : :#{the_event.to_s}"
        end
        unless options[:usage]
          options[:usage] = "{ :#{the_event.to_s} => (your_data_payload / nil) }"
        end
        unless options[:public] == true
          options[:public] = false
        end
        @interface[(the_event)] = {:description => options[:description], :usage => options[:usage], :public => (options[:public] || false), :users => (options[:users] || false), :administrators => true, :procedure => block}
        true
      end
      #
      def call_event(operation_envelope=nil, credential=(::GxG::DB[:administrator] || :"00000000-0000-4000-0000-000000000000"))
        result = nil
        if operation_envelope.is_a?(::Hash)
          the_event = operation_envelope.keys[0]
          if the_event
            data = operation_envelope[(the_event)]
            if @interface[(the_event)]
              begin
                can_call = false
                if credential == :"00000000-0000-4000-0000-000000000000" && @interface[(the_event)][:public] == true
                  can_call = true
                else
                  if  ::GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:administrators].to_s.to_sym, credential)
                    if @interface[(the_event)][:administrators] == true
                      can_call = true
                    end
                  else
                    if ::GxG::valid_uuid?(credential) && @interface[(the_event)][:users] == true && credential != :"00000000-0000-4000-0000-000000000000"
                      can_call = true
                    end
                  end
                end
               #
                if can_call
                  result = {:result => @interface[(the_event)][:procedure].call(data, credential)}
                else
                  result = {:result => nil, :error => "You Do Not Have Sufficient Permissions for Command #{the_event.inspect}"}
                end
              rescue Exception => the_error
                log_error({:error => the_error, :parameters => {:data => data, :credential => credential}})
                result = {:result => nil, :error => the_error.to_s}
              end
            else
              result = {:result => nil, :error => "Command #{the_event.inspect} Not Found"}
            end
          end
        end
        result
      end
      #
      def interface(credential=:"00000000-0000-4000-0000-000000000000")
        result = {}
        is_administrator = ::GxG::DB[:authority].role_member?(::GxG::DB[:authority][:system_credentials][:administrators].to_s.to_sym, credential)
        @interface.each_pair do |the_event, the_record|
          can_view = false
          if credential == :"00000000-0000-4000-0000-000000000000" && the_record[:public] == true
            can_view = true
          else
            if  is_administrator == true
              if the_record[:administrators] == true
                can_view = true
              end
            else
              if ::GxG::valid_uuid?(credential) && the_record[:users] == true && credential != :"00000000-0000-4000-0000-000000000000"
                can_view = true
              end
            end
          end
         #
          if can_view == true
            result[(the_event)] = (the_record[:description] + ", Usage : " + the_record[:usage])
          end
        end
        result
      end
      #
      def respond_to_event?(the_event=nil)
        result = false
        if the_event.is_a?(::Symbol)
          if @interface[(the_event)]
            result = true
          end
        end
        result
      end
      #
    end
    # ### Universal Resource Access (URA) for Services
    class UniversalResourcesAccess
      # ???
      def initialize()
        # VFS Lock format: {:path => "", :resource => File/DB_Object}
        @thread_safety_read = ::Mutex.new
        @read_locks = {}
        @thread_safety_write = ::Mutex.new
        @write_locks = {}
        self
      end
      #
      def busy?(the_path="")
        result = false
        # @thread_safety_read.synchronize {
        #   @read_locks.keys.each do |the_token|
        #     if @read_locks[(the_token)][:path] == the_path
        #       result = true
        #       break
        #     end
        #   end
        # }
        unless result == true
          @thread_safety_write.synchronize {
            @write_locks.keys.each do |the_token|
              if @write_locks[(the_token)][:path] == the_path
                result = true
                break
              end
            end
          }
        end
        result
      end
      #
      def exist?(the_path="")
        ::GxG::VFS.exist?(the_path)
      end
      #
      def profile(the_path="", credential=:"00000000-0000-4000-0000-000000000000", options={})
        ::GxG::VFS.profile(the_path, options.merge({:with_credential => credential}))
      end
      #
      def entries(the_path="", credential=:"00000000-0000-4000-0000-000000000000", options={})
        ::GxG::VFS.entries(the_path, credential)
      end
      #
      def permissions(the_path="", credential=:"00000000-0000-4000-0000-000000000000")
        the_profile = self.profile(the_path, credential)
        if the_profile
          the_profile[:permissions][:effective]
        else
          {:execute => false, :rename => false, :move => false, :destroy => false, :create => false, :write => false, :read=>false}
        end
      end
      #
      def get_permissions(the_path="", credential=:"00000000-0000-4000-0000-000000000000")
        ::GxG::VFS.get_permissions(the_path, credential)
      end
      #
      def set_permissions(the_path="", credential=:"00000000-0000-4000-0000-000000000000", permissions={})
        ::GxG::VFS.set_permissions(the_path, credential, permissions)
      end
      #
      def set_permissions_recursive(the_path="", credential=:"00000000-0000-4000-0000-000000000000", permissions={})
        ::GxG::VFS.set_permissions_recursive(the_path, credential, permissions)
      end
      #
      def revoke_permissions(the_path="", credential=:"00000000-0000-4000-0000-000000000000")
        GxG::VFS.revoke_permissions(the_path, credential)
      end
      #
      def rename(the_path="", credential=:"00000000-0000-4000-0000-000000000000", new_name="")
        result = nil
        if self.busy?(the_path)
          result = {:result => false, :error => "Busy", :error_code => :busy}
        end
        unless result
          if self.permissions(the_path, credential)[:rename] == false
            result = {:result => false, :error => "Permission Error", :error_code => :permission}
          end
        end
        unless result
          result = {:result => ::GxG::VFS.rename(the_path, new_name)}
        end
        result
      end
      #
      def copy(the_path="", credential=:"00000000-0000-4000-0000-000000000000", new_path="")
        result = nil
        if self.busy?(the_path)
          result = {:result => false, :error => "Busy", :error_code => :busy}
        end
        unless result
          if self.permissions(File.dirname(new_path), credential)[:create] == false
            result = {:result => false, :error => "Permission Error", :error_code => :permission}
          end
        end
        unless result
          result = {:result => ::GxG::VFS.copy(the_path, new_path)}
        end
        result
      end
      #
      def move(the_path="", credential=:"00000000-0000-4000-0000-000000000000", new_path="")
        result = nil
        if self.busy?(the_path)
          result = {:result => false, :error => "Busy", :error_code => :busy}
        end
        unless result
          if self.permissions(the_path, credential)[:move] == false
            result = {:result => false, :error => "Permission Error", :error_code => :permission}
          end
        end
        unless result
          result = {:result => ::GxG::VFS.move(the_path, new_path)}
        end
        result
      end
      #
      def destroy(the_path="", credential=:"00000000-0000-4000-0000-000000000000")
        result = nil
        if self.busy?(the_path)
          result = {:result => false, :error => "Busy", :error_code => :busy}
        end
        unless result
          if self.permissions(the_path, credential)[:destroy] == false
            result = {:result => false, :error => "Permission Error", :error_code => :permission}
          end
        end
        unless result          
          result = {:result => ::GxG::VFS.destroy(the_path, credential)}
        end
        result
      end
      #
      def create(the_path="", credential=:"00000000-0000-4000-0000-000000000000", options={})
        result = nil
        if self.busy?(the_path)
          result = {:result => false, :error => "Busy", :error_code => :busy}
        end
        unless result
          if self.permissions(File.dirname(the_path), credential)[:create] == false
            result = {:result => false, :error => "Permission Error", :error_code => :permission}
          end
        end
        unless result
          handle = ::GxG::VFS.mkfile(the_path, options)
          if handle
            if handle.is_a?(::GxG::Database::PersistedHash)
              handle.set_permissions(credential, {:execute => false, :rename => true, :move => true, :destroy => true, :create => true, :write => true, :read=>true})
              handle.deactivate
              result = {:result => true}
            else
              # FS
              # Review : Create a extra layer of permission tracking (by path) of files and directories on the actual file system. This puts it at parity with DB Objects.
              if handle.is_a?(::File)
                handle.close
              end
              result = {:result => true}
            end
          else
            result = {:result => false, :error => "Creation Error", :error_code => :create_fail}
          end
        end
        result
      end
      #
      def create_directory(the_path="", credential=:"00000000-0000-4000-0000-000000000000", options={})
        #result = {:result => false}
        result = nil
        if self.permissions(File.dirname(the_path), credential)[:create] == false
          result = {:result => false, :error => "Permission Error", :error_code => :permission}
        end
        unless result
          if ::GxG::VFS.mkdir(the_path)
            the_profile = self.profile(the_path)
            if the_profile[:uuid]
              handle = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_profile[:uuid], ::GxG::DB[:administrator])
              if handle.is_a?(::GxG::Database::PersistedArray)
                handle.set_permissions(credential, {:execute => false, :rename => true, :move => true, :destroy => true, :create => true, :write => true, :read=>true})
                result = {:result => true}
              else
                result = {:result => false, :error => "Creation Error", :error_code => :create_fail}
              end
            else
              # FS
              # Review : Create a extra layer of permission tracking (by path) of files and directories on the actual file system. This puts it at parity with DB Objects.
              result = {:result => true}
            end
          else
            result = {:result => false, :error => "Creation Error", :error_code => :create_fail}
          end
        end
        result
      end
      #
      def open(the_path="", credential=:"00000000-0000-4000-0000-000000000000", flags=[:read, :binary])
        result = nil
        if ::GxG::valid_uuid?(credential) && flags.is_a?(::Array)
          if self.permissions(the_path, credential)[:read] == true
            the_flags = []
            flags.each do |a_flag|
              unless [:readwrite, :write].include?(a_flag)
                the_flags << a_flag
              end
            end
            supplimental_flags = []
            unless the_flags.include?(:read)
              supplimental_flags << :read
            end
            unless the_flags.include?(:binary)
              supplimental_flags << :binary
            end
            the_resource = ::GxG::VFS.open(the_path, {:flags => [(the_flags),(supplimental_flags)].flatten})
            if the_resource
              the_token = ::GxG::uuid_generate.to_sym
              @thread_safety_read.synchronize {
                @read_locks[(the_token)] = {:path => the_path, :resource => the_resource}
              }
              result = {:token => the_token, :path => the_path, :resource => the_resource}
            end
          end
        end
        result
        #
      end
      #
      def open_writable(the_path="", credential=:"00000000-0000-4000-0000-000000000000", flags=[:readwrite, :binary])
        result = nil
        if ::GxG::valid_uuid?(credential) && flags.is_a?(::Array)
          if self.permissions(the_path, credential)[:write] == true
            someone_else_locked = false
            @thread_safety_write.synchronize {
              @write_locks.keys.each do |the_write_token|
                if @write_locks[(the_write_token)][:path] == the_path
                  someone_else_locked = true
                  break
                end
              end
            }
            #
            unless someone_else_locked == true
              supplimental_flags = []
              unless flags.include?(:readwrite)
                supplimental_flags << :readwrite
              end
              unless flags.include?(:binary)
                supplimental_flags << :binary
              end
              the_resource = ::GxG::VFS.open(the_path, {:flags => [(flags),(supplimental_flags)].flatten})
              if the_resource
                the_token = ::GxG::uuid_generate.to_sym
                @thread_safety_write.synchronize {
                  @write_locks[(the_token)] = {:path => the_path, :resource => the_resource}
                }
                result = {:token => the_token, :path => the_path, :resource => the_resource}
              end
            end
            #
          end
          #
        end
        result
      end
      #
      def reopen_writable(the_token="", credential=:"00000000-0000-4000-0000-000000000000", flags=[])
        result = nil
        if ::GxG::valid_uuid?(the_token)
          details = nil
          someone_else_locked = false
          @thread_safety_read.synchronize {
            if @read_locks[(the_token.to_sym)]
              details = @read_locks.delete(the_token.to_sym)
            end
          }
          if details
            # ONLY converts read-locks to write-locks. Be sure to use open first.
            @thread_safety_write.synchronize {
              @write_locks.keys.each do |the_write_token|
                if @write_locks[(the_write_token)][:path] == details[:path] && the_token.to_sym != the_write_token
                  someone_else_locked = true
                  break
                end
              end
            }
            unless someone_else_locked == true
              if details[:resource].is_any?(::GxG::Database::PersistedArray, ::GxG::Database::PersistedHash)
                details[:resource].wait_for_reservation(5.0)
                if details[:resource].write_reserved?()
                  @thread_safety_write.synchronize {
                    @write_locks[(the_token.to_sym)] = details
                  }
                  result = details
                else
                  @thread_safety_read.synchronize {
                    @read_locks[(the_token.to_sym)] = details
                  }
                end
              else
                if details[:resource].is_a?(::Dir)
                  if self.permissions(details[:path], credential)[:write] == true
                    @thread_safety_write.synchronize {
                      @write_locks[(the_token.to_sym)] = details
                    }
                    result = details
                  else
                    @thread_safety_read.synchronize {
                      @read_locks[(the_token.to_sym)] = details
                    }
                  end
                else
                  if details[:resource].is_a?(::File)
                    if self.permissions(details[:path], credential)[:write] == true
                      details[:resource].close
                      details[:resource] = ::GxG::VFS.open(details[:path], {:flags => [:readwrite, :binary]})
                      @thread_safety_read.synchronize {
                        @write_locks[(the_token.to_sym)] = details
                      }
                      result = details
                    else
                      @thread_safety_read.synchronize {
                        @read_locks[(the_token.to_sym)] = details
                      }
                    end
                  end
                end
              end
            end
          end
        end
        result
      end
      #
      def reopen_readonly(the_token="", credential=:"00000000-0000-4000-0000-000000000000", flags=[])
        result = nil
        if ::GxG::valid_uuid?(the_token) && ::GxG::valid_uuid?(credential) && flags.is_a?(::Array)
          the_flags = []
          flags.each do |a_flag|
            unless [:readwrite, :write].include?(a_flag)
              the_flags << a_flag
            end
          end
          supplimental_flags = []
          unless the_flags.include?(:read)
            supplimental_flags << :read
          end
          unless the_flags.include?(:binary)
            supplimental_flags << :binary
          end
          details = nil
          @thread_safety_write.synchronize {
            if @write_locks[(the_token.to_sym)]
              details = @write_locks.delete(the_token.to_sym)
            end
          }
          if details
            if self.permissions(details[:path], credential)[:read] == true
              if details[:resource].is_any?(::GxG::Database::PersistedArray, ::GxG::Database::PersistedHash)
                details[:resource].release_reservation()
                @thread_safety_read.synchronize {
                  @read_locks[(the_token.to_sym)] = details
                }
                result = details
              else
                if details[:resource].is_a?(::Dir)
                  @thread_safety_read.synchronize {
                    @read_locks[(the_token.to_sym)] = details
                  }
                  result = details
                else
                  if details[:resource].is_a?(::File)
                    details[:resource].close
                    details[:resource] = ::GxG::VFS.open(details[:path], {:flags => [:read, :binary]})
                    @thread_safety_read.synchronize {
                      @read_locks[(the_token.to_sym)] = details
                    }
                    result = details
                  end
                end
              end
            else
              @thread_safety_write.synchronize {
                @write_locks[(the_token.to_sym)] = details
              }
            end
          end
        end
        result
      end
      #
      def close(the_token="")
        result = false
        if ::GxG::valid_uuid?(the_token)
          details = nil
          @thread_safety_read.synchronize {
            if @read_locks[(the_token.to_sym)]
              details = @read_locks.delete(the_token.to_sym)
            end
          }
          unless details
            @thread_safety_write.synchronize {
              if @write_locks[(the_token.to_sym)]
                details = @write_locks.delete(the_token.to_sym)
              end
            }
          end
          if details
            # VFS Lock format: {:path => "", :resource => File/DB_Object}
            if details[:resource]
              if details[:resource].is_a?(::Dir)
                # Review : ??
              else
                if details[:resource].is_a?(::File)
                  details[:resource].close
                else
                  if details[:resource].is_any?(::GxG::Database::PersistedArray, ::GxG::Database::PersistedHash)
                    details[:resource].deactivate
                  else
                    # err
                  end
                end
              end
              result = true
            end
          end
        end
        result
      end
      # ### User Home Directory Supports
      def home_mounted?(credential=nil)
        result = false
        if GxG::valid_uuid?(credential)
          if GxG::VFS.exist?(("/Users/" + credential.to_s))
            result = true
          end
        end
        result
      end
      #
      def home_mount(credential=nil)
        result = false
        if self.home_mounted?(credential)
          unless GxG::VFS.mounted?("/User/#{credential.to_s}/Database")
            volume_stub = GxG::DB[:roles][:vfs].search_database(credential, {:title => ("volume-" + credential.to_s)}).first
            if volume_stub
              volume_uuid = volume_stub[:uuid]
            else
              volume_persisted_array = GxG::DB[:roles][:vfs].try_persist([], credential)
              volume_uuid = volume_persisted_array.uuid
              volume_persisted_array.get_reservation()
              volume_persisted_array.set_title("volume-" + credential.to_s)
              volume_persisted_array.save
              volume_persisted_array.deactivate
            end
            volume_handle = GxG::Storage::Volume.new({:database => GxG::DB[:roles][:vfs], :credential => credential, :root_uuid => volume_uuid})
            GxG::VFS.mount(volume_handle, "/User/#{credential.to_s}/Database")
          end
          result = true
        else
          home_path = ("/Users/" + credential.to_s)
          manifest = [(home_path)]
          ["Preferences", "Documents", "Pictures", "Music", "Videos", "Books", "Resources", "Volumes", "Database", "ApplicationData"].each do |subdir|
            manifest << (home_path + "/" + subdir)
          end
          while manifest.size > 0 do
            entry = manifest.shift
            GxG::VFS.mkpath(entry)
            if entry == home_path
              GxG::VFS.set_permissions(home_path, GxG::DB[:authority][:system_credentials][:administrators], {:execute => false, :rename => true, :move => true, :destroy => true, :create => true, :write => true, :read=>true})
              GxG::VFS.set_permissions(home_path, credential, {:execute => false, :rename => false, :move => false, :destroy => false, :create => true, :write => true, :read=>true})
            else
              # {:execute => false, :rename => false, :move => false, :destroy => false, :create => false, :write => false, :read=>false}
              if ["Preferences","Volumes", "Database", "ApplicationData"].include?(File.basename(entry))
                # disallow delete
                GxG::VFS.set_permissions(entry, GxG::DB[:authority][:system_credentials][:administrators], {:execute => false, :rename => true, :move => true, :destroy => true, :create => true, :write => true, :read=>true})
                GxG::VFS.set_permissions(entry, credential, {:execute => false, :rename => false, :move => false, :destroy => false, :create => true, :write => true, :read=>true})
              else
                # allow delete ??
                GxG::VFS.set_permissions(entry, GxG::DB[:authority][:system_credentials][:administrators], {:execute => false, :rename => true, :move => true, :destroy => true, :create => true, :write => true, :read=>true})
                GxG::VFS.set_permissions(entry, credential, {:execute => false, :rename => false, :move => false, :destroy => false, :create => true, :write => true, :read=>true})
              end
            end
          end
          # mount Objects DB root
          volume_persisted_array = GxG::DB[:roles][:vfs].try_persist([], credential)
          volume_uuid = volume_persisted_array.uuid
          volume_persisted_array.get_reservation()
          volume_persisted_array.set_title("volume-" + credential.to_s)
          volume_persisted_array.save
          volume_persisted_array.deactivate
          volume_handle = GxG::Storage::Volume.new({:database => GxG::DB[:roles][:vfs], :credential => credential, :root_uuid => volume_uuid})
          GxG::VFS.mount(volume_handle, "/User/#{credential.to_s}/Database")
          result = true
        end
        result
      end
      #
      def home_path(credential=nil)
        if credential == :"00000000-0000-4000-0000-000000000000"
          result = "/Public/www"
        else
          # if GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:administrators], credential) || GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:developers], credential) || GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:designers], credential)
          #   result = "/"
          # else
          #   self.home_mount(credential)
          #   result = ("/Users/" + credential.to_s)
          # end
          self.home_mount(credential)
          result = ("/Users/" + credential.to_s)
        end
        result
      end
      # ###
      #
    end
    #
  end
end
# ### Define The Core Service:
core_service = ::GxG::Services::Service.new(:core)
# ### Define Public Command Interface:
core_service.on(:start, {:description => "System Service Layer Start", :usage => "{ :start => nil }", :users => false}) do
  ::GxG::SERVICES[:core].start
end
core_service.on(:stop, {:description => "System Service Layer Shutdown", :usage => "{ :stop => nil }", :users => false}) do
  ::GxG::SERVICES[:core].stop
end
core_service.on(:restart, {:description => "System Service Layer Restart", :usage => "{ :restart => nil }", :users => false}) do
  ::GxG::SERVICES[:core].restart
end
core_service.on(:pause, {:description => "System Service Pause", :usage => "{ :pause => nil }", :users => false}) do
  ::GxG::SERVICES[:core].pause
end
core_service.on(:resume, {:description => "System Service Resume", :usage => "{ :resume => nil }", :users => false}) do
  ::GxG::SERVICES[:core].resume
end
# ### Define Internal Service Control Events:
core_service.on(:at_start, {:description => "System Service Layer Startup", :usage => "{ :at_start => (service-object) }", :users => false}) do |service, credential|
  # ### Set Engine Monitors
  service.dispatcher.every("1 second") do
    ::GxG::Engine::determine_event_allocations()
    ::GxG::Engine::determine_loads()
  end
  # ### Load Services
  if service.configuration()[:available]
    service.configuration()[:available].each do |moniker|
      unless service.configuration()[:disabled].include?(moniker)
        service_file_path = ::File.expand_path("#{File.dirname(__FILE__)}/#{moniker}/#{moniker}.rb")
        if ::File.exists?(service_file_path)
          begin
            require (service_file_path)
          rescue Exception => the_error
            log_error({:error => the_error, :parameters => {:service => moniker}})
          end
        else
          log_warn("WARNING: /Services/#{moniker.to_s}/#{moniker.to_s}.rb NOT FOUND -- skipping service")
        end
      end
    end
    # ### Start Services
    ::GxG::Services::start_order().each do |the_service_moniker|
      unless the_service_moniker == :core
        if service.configuration()[:enabled].include?(the_service_moniker.to_s)
          log_info("Starting Service: #{the_service_moniker.inspect} ...")
          ::GxG::Services::start_service(the_service_moniker)
        end
      end
    end
    #
  end
  # ### Startup Scripts
  Dir.entries("#{::GxG::SYSTEM_PATHS[:system]}/Startup").each do |entry|
    if File.extname(entry) == ".rb"
      require "#{::GxG::SYSTEM_PATHS[:system]}/Startup/#{entry}"
    end
  end
  #
end
#
core_service.on(:at_stop, {:description => "System Service Layer Shutdown", :usage => "{ :at_stop => (service-object) }", :public => false}) do |service|
  # ### Stop Services
  ::GxG::Services::stop_order().each do |the_service_moniker|
    unless the_service_moniker == :core
      log_info("Stopping Service: #{the_service_moniker.inspect} ...")
      ::GxG::Services::stop_service(the_service_moniker)
    end
  end
  #
end
# ### Provide Universal Resouce Access
core_service[:resources] = ::GxG::Services::UniversalResourcesAccess.new()
#
unless core_service.configuration()[:available]
  core_service.configuration()[:available] = []
  core_service.configuration()[:enabled] = []
  core_service.configuration()[:disabled] = []
  core_service.save_configuration
  ::GxG::VFS.entries("/Services").each do |the_profile|
    if the_profile[:type] == :directory
      ::GxG::Services::install_service(the_profile[:title].to_sym)
      ::GxG::Services::enable_service(the_profile[:title].to_sym)
    end
  end
end
core_service.start
# ### Trap for exit signals
unless RUBY_ENGINE == "jruby"
  Signal.trap("QUIT") do
    ::GxG::Services::stop_service(:core)
    exit(0)
  end
end
Signal.trap("INT") do
  ::GxG::Services::stop_service(:core)
  exit(0)
end
Signal.trap("TERM") do
  ::GxG::Services::stop_service(:core)
  exit(0)
end
# ### Review : USR1 in use by JVM/JRuby and won't work.
# Signal.trap("USR1") do
#   ::GxG::Services::stop_service(:core)
# end
Signal.trap("HUP") do
  ::GxG::Services::stop_service(:core)
  exit(0)
end
#
unless ($0 == "irb" || $0 == "jirb" || Module.constants.include?(:IRB))
  # ### Place-holder loop for running in the background
  while true do
    sleep 5.0
  end
end
