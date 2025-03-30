#!/usr/bin/env jruby
if ARGV.include?("--quiet")
  STDIN.reopen("/dev/null", "r")
  STDOUT.reopen("/dev/null", "w")
  STDERR.reopen("/dev/null", "w")
end
require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'
#
module Gem::UserInteraction
	def terminate_interaction(exit_code = 0)
		# Suppress the instruction to exit ruby:
		# ui.terminate_interaction exit_code
	  end
end
#
class Object
	private
	def gem_command(commands=nil)
		if commands.is_a?(::String)
			Gem::GemRunner.new.run commands.split(" ")
		end
	end
	public
end
#
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
# Ensure specs dir is present
if Dir.exist?(GxG::SYSTEM_PATHS[:gems])
  unless Dir.exist?("#{GxG::SYSTEM_PATHS[:gems]}/specs")
    begin
      FileUtils.mkpath("#{GxG::SYSTEM_PATHS[:gems]}/specs")
    rescue Exception => error
      log_error({:error => error, :parameters => "#{GxG::SYSTEM_PATHS[:gems]}/specs"})
    end
  end
else
  begin
    FileUtils.mkpath("#{GxG::SYSTEM_PATHS[:gems]}/specs")
  rescue Exception => error
    log_error({:error => error, :parameters => "#{GxG::SYSTEM_PATHS[:gems]}/specs"})
  end
end
# Setup Rubygems paths
ENV['GEM_HOME']=GxG::SYSTEM_PATHS[:gems]
ENV['GEM_SPEC_CACHE']="#{GxG::SYSTEM_PATHS[:gems]}/specs"
ENV['GEM_PATH']=[(GxG::SYSTEM_PATHS[:gems]), (Gem.paths.path)].flatten.join(":")
Gem.clear_paths
Gem.paths = ENV
#
class Object
	private
	def gem_install(gem_name=nil,version_info=nil)
		if gem_name.is_any?(::String, ::Symbol) && version_info.is_any?(::String, ::NilClass)
			if version_info
        gem_command("install --install-dir #{GxG::SYSTEM_PATHS[:gems]} --version #{version_info.to_s} #{gem_name.to_s}")
      else
        gem_command("install --install-dir #{GxG::SYSTEM_PATHS[:gems]} #{gem_name.to_s}")
      end
    else
      raise Exception, "Invalid gem or version specifier"
    end
	end
	public
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
::GxG::VFS.mount(::GxG::Storage::Volume.new({:directory => ::GxG::SYSTEM_PATHS[:installers]}), "/Installers")
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
          # ::GxG::SERVICES[(moniker)].start
          ::GxG::SERVICES[(moniker)].call_event({:start => nil})
        end
      end
    end
    #
    def self.stop_service(moniker=nil)
      if moniker.is_a?(::Symbol)
        if ::GxG::SERVICES[(moniker)]
          # ::GxG::SERVICES[(moniker)].stop
          ::GxG::SERVICES[(moniker)].call_event({:stop => nil})
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
      # ### API Support
      def publish_route(the_method=:get, path="", options={}, &block)
        if ::GxG::Services::service_available?(:www)
          ::GxG::SERVICES[:www].call_event({:publish_route => {:http_method => the_method, :path => path, :options => options, :code => block}}, ::GxG::DB[:administrator])
        end
      end
      def publish_api()
        if ::GxG::Services::service_available?(:www)
          ::GxG::SERVICES[:www].call_event({:publish_api => {:service => self, :path => "/#{@provides.to_s}"}}, ::GxG::DB[:administrator])
        end
      end
      def unpublish_api()
        if ::GxG::Services::service_available?(:www)
          ::GxG::SERVICES[:www].call_event({:unpublish_api => {:path => "/#{@provides.to_s}"}}, ::GxG::DB[:administrator])
        end
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
          the_profile = self.profile(the_path, credential)
          if [:virtual_directory, :directory, :persisted_array].include?(the_profile[:type])
            result = {:result => ::GxG::VFS.rmdir(the_path)}
          else
            result = {:result => ::GxG::VFS.rmfile(the_path)}
          end
          # xxx
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
      def mark_busy(the_path="")
        the_token = ::GxG::uuid_generate.to_sym
        @thread_safety_write.synchronize {
          @write_locks[(the_token)] = {:path => the_path, :resource => true}
        }
        {:token => the_token, :path => the_path, :resource => true}
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
    # ### Installer Support
    class SoftwareInstaller
      #
      def initialize(archive_name=nil)
        #
        unless archive_name.is_a?(::String)
          raise "You MUST provide a valid installer archive name as a String."
        end
        unless ::GxG::SERVICES[:core][:resources].exist?("/Installers/#{archive_name}")
          raise "Archive #{archive_name} does not exist."
        end
        if ::GxG::SERVICES[:core][:resources].busy?("/Installers/#{archive_name}")
          raise "Archive #{archive_name} is in use currently."
        end
        #
        @manifest = nil
        @database = nil
        @archive_token = ::GxG::SERVICES[:core][:resources].open("/Installers/#{archive_name}", GxG::DB[:administrator])
        if @archive_token
          @database = ::GxG::Database::connect(::URI.parse("sqlite://#{::GxG::SYSTEM_PATHS[:installers]}/#{archive_name}"), {:read_only => true})
          unless @database.is_a?(::GxG::Database::Database)
            ::GxG::SERVICES[:core][:resources].close(@archive_token[:token])
            raise "Unable to open #{archive_name}"
          end
          @installer_path = "/Installers/#{::GxG::uuid_generate()}"
          @manifest = ::JSON::parse(@database[:installation_manifest].to_s.decode64, {:symbolize_names => true})
          @manifest[:formats].each_pair do |format_uuid, format_record|
            format_record[:content] = ::Hash::gxg_import(format_record[:content])
          end
          ::GxG::VFS.mount(::GxG::Storage::Volume.new({:database => @database, :credential => GxG::DB[:administrator]}), @installer_path)
        else
          raise "Unable to secure a read-access token for: #{archive_name}"
        end
        #
        self
      end
      #
      def open?()
        if @database.is_a?(::GxG::Database::Database)
          true
        else
          false
        end
      end
      #
      def close()
        if @archive_token.is_a?(::Hash)
          ::GxG::SERVICES[:core][:resources].close(@archive_token[:token])
          ::GxG::VFS.unmount(@installer_path)
          @archive_token = nil
          if @database.is_a?(::GxG::Database::Database)
            @database.close
            @database = nil
          end
        end
        true
      end
      #
      def perform_install(options={})
        begin
          if self.open?() && @manifest.is_a?(::Hash)
            # flesh out manifest
            # manifest format: {:package => "", :version => "0.0", :gems => {}, :formats => {}, objects => {:"path/to/file" => [{:users => {:read => true}}]}}
            # Install Gems
            @manifest[:gems].each_pair do |gem_name, version_info|
              gem_install(gem_name, version_info)
            end
            # copy formats
            ::GxG::DB[:roles][:formats].sync_import(GxG::DB[:administrator], {:formats => (@manifest[:formats] || {}), :records => []})
            # copy files into place, setting permissions          
            if @manifest[:objects].is_a?(::Hash)
              @manifest[:objects].each_pair do |the_path, the_permissions|
                if ::GxG::SERVICES[:core][:resources].exist?(the_path.to_s)
                  existing_permissions = ::GxG::VFS.get_permissions(the_path.to_s)
                else
                  existing_permissions = nil
                end
                ::GxG::SERVICES[:core][:resources].copy("#{@installer_path}#{the_path.to_s}", GxG::DB[:administrator], the_path.to_s)
                if the_permissions.is_a?(::Array)
                  ::GxG::SERVICES[:core][:resources].set_permissions(the_path.to_s, :"00000000-0000-4000-0000-000000000000", {:write => false, :read => false})
                  ::GxG::SERVICES[:core][:resources].revoke_permissions(the_path.to_s, :"00000000-0000-4000-0000-000000000000")
                  #
                  the_permissions.each do |the_entry|
                    if the_entry.is_a?(::Hash)
                      #
                      the_credential = nil
                      case the_entry.keys[0]
                      when :public
                        the_credential = :"00000000-0000-4000-0000-000000000000"
                      when :users
                        the_credential = ::GxG::DB[:users]
                      when :designers
                        the_credential = ::GxG::DB[:designers]
                      when :developers
                        the_credential = ::GxG::DB[:developers]
                      when :administrators
                        the_credential = ::GxG::DB[:administrators]
                      end
                      if the_credential
                        ::GxG::SERVICES[:core][:resources].set_permissions(the_path.to_s, the_credential, (the_entry.values[0] || {:read => true}))
                      end
                      #
                    end
                  end
                  #
                  if existing_permissions.is_a?(::Array)
                    existing_permissions.each do |entry|
                      ::GxG::SERVICES[:core][:resources].set_permissions(the_path.to_s, entry[:credential], entry[:permissions])
                    end
                  end
                  #
                end
              end
            end
            result = true
          else
            result = false
          end
        rescue Exception => the_error
          log_error({:error => the_error})
          result = false
        end
        result
      end
      #
    end
    #
    class SoftwareInstallerMaker
      private
      #
      def portable_format(the_format_record=nil)
        result = nil
        if the_format_record.is_any?(::Hash, ::GxG::Database::DetachedHash, ::GxG::Database::PersistedHash)
          if the_format_record.is_any?(::GxG::Database::DetachedHash, ::GxG::Database::PersistedHash)
            the_format_record = the_format_record.unpersist
          end
          if (the_format_record[:uuid] && the_format_record[:type] && the_format_record[:ufs] && the_format_record[:version] && the_format_record[:mime_types])
            #
            result = {:uuid => (the_format_record[:uuid]), :type => (the_format_record[:type]), :ufs => (the_format_record[:ufs]), :title => (the_format_record[:title].to_s), :version => (the_format_record[:version]), :mime_types => (the_format_record[:mime_types] || []), :content => the_format_record[:content].gxg_export}
            #
          else
            raise "Malformed format record"
          end
        else
          raise "Malformed format record"
        end
        result
      end
      #
      def portable_permission(credential=nil, permissions=nil)
        result = nil
        if ::GxG::valid_uuid?(credential) && permissions.is_a?(::Hash)
          if credential == :"00000000-0000-4000-0000-000000000000"
            the_role = :public
          else
            the_role = nil
            [:administrators, :developers, :designers, :users].each do |entry|
              if credential == ::GxG::DB[(entry)]
                the_role = entry
                break
              end
            end
          end
          if the_role
            result = {}
            result[(the_role)] = permissions
          end
        end
        result
      end
      #
      public
      #
      def initialize()
        @manifest = {:package => nil, :version => "0.0", :gems => {}, :formats => {}, :objects => {}}
        self
      end
      #
      def package()
        @manifest[:package]
      end
      #
      def package=(package_name=nil)
        if package_name
          @manifest[:package] = package_name.to_s[0..127]
        end
      end
      #
      def version()
        ::BigDecimal.new(@manifest[:version])
      end
      #
      def version=(the_version=nil)
        if the_version.is_any?(::String, ::BigDecimal)
          @manifest[:version] = the_version.to_s
        else
          raise "You MUST provide a String or BigDecimal as version number"
        end
        #
        def add_gem(gem_name=nil, version_info=nil)
          if gem_name.is_any?(::String, ::Symbol) && version_info.is_any?(::String, ::NilClass)
            @manifest[:gems][gem_name.to_s.to_sym] = version_info
            true
          else
            false
          end
        end
        #
        def add_format_from_uuid(the_uuid=nil)
          the_format_record = ::GxG::DB[:roles][:formats].format_load({:uuid => the_uuid})
          unless the_format_record
            the_format_record = ::GxG::DB[:formats][(the_uuid.to_s.to_sym)]
          end
          if the_format_record.is_a?(::Hash)
            portable_record = portable_format(the_format_record)
            if portable_record
              @manifest[:formats][(the_format_record[:uuid].to_s.to_sym)] = portable_record
              true
            else
              false
            end
          else
            false
          end
        end
        #
        def add_format_from_ufs(the_ufs=nil)
          the_format_record = ::GxG::DB[:roles][:formats].format_load({:ufs => the_ufs})
          unless the_format_record
            ::GxG::DB[:formats].values.each do |entry|
              if entry[:ufs] == the_ufs
                the_format_record = entry
                break
              end
            end
          end
          if the_format_record.is_a?(::Hash)
            portable_record = portable_format(the_format_record)
            if portable_record
              @manifest[:formats][(the_format_record[:uuid].to_s.to_sym)] = portable_record
              true
            else
              false
            end
          else
            false
          end
        end
        #
        def add_format_from_record(the_format_record=nil)
          if (the_format_record[:uuid] && the_format_record[:type] && the_format_record[:ufs] && the_format_record[:version] && the_format_record[:mime_types])
            portable_record = portable_format(the_format_record)
            if portable_record
              @manifest[:formats][(the_format_record[:uuid].to_s.to_sym)] = portable_record
              true
            else
              false
            end
          else
            raise "Malformed format record"
          end
        end
        #
        def add_path(the_path=nil)
          if the_path.is_a?(::String)
            the_profile = ::GxG::SERVICES[:core][:resources].profile(the_path, ::GxG::DB[:administrator])
            #
            if [:virtual_directory, :directory, :persisted_array].include?(the_profile[:type])
              processing_db = [(the_path)]
              while processing_db.size > 0
                item = processing_db.shift
                if item
                  subitems = ::GxG::SERVICES[:core][:resources].entries(item, ::GxG::DB[:administrator])
                  #
                  if subitems.size == 0
                    @manifest[:objects][(item.to_s.to_sym)] = []
                    ::GxG::VFS.get_permissions(item).each do |entry|
                      the_permission = portable_permission(entry[:credential], entry[:permissions])
                      if the_permission
                        @manifest[:objects][(item.to_s.to_sym)] << the_permission
                      end
                    end
                  end
                  #
                  if subitems.size > 0
                    subitems.each do |profile|
                      subpath = (item + "/" + profile[:title])
                      if [:virtual_directory, :directory, :persisted_array].include?(profile[:type])
                        processing_db << subpath
                      else
                        @manifest[:objects][(subpath.to_s.to_sym)] = []
                        ::GxG::VFS.get_permissions(subpath).each do |entry|
                          the_permission = portable_permission(entry[:credential], entry[:permissions])
                          if the_permission
                            @manifest[:objects][(subpath.to_s.to_sym)] << the_permission
                          end
                        end
                      end
                    end
                  end
                  #
                end
              end
            else
              @manifest[:objects][(the_path.to_s.to_sym)] = []
              ::GxG::VFS.get_permissions(the_path).each do |entry|
                the_permission = portable_permission(entry[:credential], entry[:permissions])
                if the_permission
                  @manifest[:objects][(the_path.to_s.to_sym)] << the_permission
                end
              end
            end
            #
            true
          else
            raise "Malformed path String"
          end
        end
        #
        def make_installer()
          result = false
          #
          if @manifest[:package]
            archive_name = (@manifest[:package].to_s.gsub(" ","-") + "_" + @manifest[:version].to_s.gsub(".","-") + ".gxg_installer")
            installer_path = "/Installers/#{::GxG::uuid_generate()}"
            database = ::GxG::Database::connect(::URI.parse("sqlite://#{::GxG::SYSTEM_PATHS[:installers]}/#{archive_name}"))
            unless database.is_a?(::GxG::Database::Database)
              raise "Unable to open #{archive_name}"
            end
            archive_token = ::GxG::SERVICES[:core][:resources].mark_busy("/Installers/#{archive_name}")
            ::GxG::VFS.mount(::GxG::Storage::Volume.new({:database => database, :credential => GxG::DB[:administrator]}), installer_path)
            begin
              database[:installation_manifest] = @manifest.to_json.encode64
              @manifest[:objects].keys.each do |the_path|
                ::GxG::SERVICES[:core][:resources].copy(the_path.to_s, GxG::DB[:administrator], "#{installer_path}#{the_path.to_s}")
                ::GxG::SERVICES[:core][:resources].set_permissions("#{installer_path}#{the_path.to_s}", :"00000000-0000-4000-0000-000000000000", {:read => true})
              end
              @manifest[:objects].keys.each do |the_path|
                ::GxG::SERVICES[:core][:resources].revoke_permissions("#{installer_path}#{the_path.to_s}", ::GxG::DB[:users])
                ::GxG::SERVICES[:core][:resources].revoke_permissions("#{installer_path}#{the_path.to_s}", ::GxG::DB[:designers])
                ::GxG::SERVICES[:core][:resources].revoke_permissions("#{installer_path}#{the_path.to_s}", ::GxG::DB[:developers])
                ::GxG::SERVICES[:core][:resources].revoke_permissions("#{installer_path}#{the_path.to_s}", ::GxG::DB[:administrators])
              end
              #
              ::GxG::VFS.unmount(installer_path)
              database.close
              ::GxG::SERVICES[:core][:resources].close(archive_token[:token])
              result = true
            rescue Exception => the_error
              ::GxG::VFS.unmount(installer_path)
              database.close
              ::GxG::SERVICES[:core][:resources].close(archive_token[:token])
              ::GxG::SERVICES[:core][:resources].destroy(("/Installers/#{archive_name}"), ::GxG::DB[:administrator])
              log_error({:error => the_error})
              raise the_error
            end
          else
            raise "You MUST first set the package name"
          end
          #
          result
        end
        #
      end
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
      begin
        require "#{::GxG::SYSTEM_PATHS[:system]}/Startup/#{entry}"
      rescue Exception => the_error
        log_error({:error => the_error})
      end
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
    sleep 5
  end
end
