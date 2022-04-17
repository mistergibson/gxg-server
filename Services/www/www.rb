#!/usr/bin/env ruby
#
# ### Standard Ruby is fine for small installations and development.
# ### JRuby is best for scaled production as it uses *real* threads for each request.
# ### WEBrick was chosen for its sheer simplicity. When combined with JRuby it performs suprisingly well.
# ### DO NOT use with puma or rainbow or unicorn as this is a unitary NON-forking design. (feature != bug)
#
require "securerandom"
require "logger"
require "webrick"
# module WEBrick
#     class Cookie
#         def to_s
#           ret = ""
#           ret << @name << "=" << @value
#           ret << "; " << "Version=" << @version.to_s if @version > 0
#           ret << "; " << "Domain="  << @domain  if @domain
#           ret << "; " << "Expires=" << @expires if @expires
#           ret << "; " << "Max-Age=" << @max_age.to_s if @max_age
#           ret << "; " << "Comment=" << @comment if @comment
#           ret << "; " << "Path="    << @path if @path
#           ret << "; " << "Secure"   if @secure
#         #   ret << "; " << "SameSite=Lax"
#           ret
#         end
#     end
# end
require "webrocket"
# See: https://github.com/unak/WEBrocket
require "sinatra/base"
require "sinatra/webdav"
require "sinatra/contrib/all"
# See: http://sinatrarb.com/contrib/streaming.html
#
# GxG WWW Initialization
www_service = ::GxG::Services::Service.new(:www)
www_paths = {:www_public => "#{::GxG::SYSTEM_PATHS[:public]}/www"}
www_paths[:www_themes] = "#{www_paths[:www_public]}/themes"
www_paths[:www_javascript] = "#{www_paths[:www_public]}/javascript"
www_paths[:www_images] = "#{www_paths[:www_public]}/images"
www_paths[:www_audio] = "#{www_paths[:www_public]}/audio"
www_paths[:www_video] = "#{www_paths[:www_public]}/video"
www_paths.values.each do |a_path|
  unless Dir.exist?(a_path)
    begin
      FileUtils.mkpath(a_path, 0755)
    rescue Exception => error
      log_error({:error => error, :parameters => a_path})
    end
  end
end
www_paths.each_pair do |moniker, path|
    ::GxG::SYSTEM_PATHS[(moniker)] = path
end
# ### Sinatra Bootstrap
class Node0 < Sinatra::Application
    enable :sessions
    # use Rack::Session::Cookie, {:key => "rack.session", :expire_after => 318513600, :same_site => :strict, :secure => true}
    #
    helpers Sinatra::Streaming
    register Sinatra::WebDAV
    configure do
        set :backend, WEBrick
        set :environment, (::GxG::SERVICES[:www].configuration[:mode] || "production").to_sym
        set :bind, ((::GxG::SERVICES[:www].configuration[:listen] || [])[0] || {:address => "127.0.0.1"})[:address]
        set :port, ((::GxG::SERVICES[:www].configuration[:listen] || [])[0] || {:port => 32767})[:port].to_i
        set :sessions, true
        set :root, ::GxG::SYSTEM.gxg_root()
        set :public_folder, ::GxG::SYSTEM_PATHS[:www_public]
        set :logging, true
        set :logger, ::GxG::LOG
        secret = ::GxG::uuid_generate.to_s
        set :session_secret, secret
        use Rack::Session::Pool, {:expire_after => 318513600, :secure => false}
        use Rack::Session::Cookie, {:key => 'rack.session', :path => '/', :expire_after => 318513600, :secret => secret, :secure => false}
    end
    # ### Extend Sinatra Verbs
    # DAV Class 1 Supports
    #     def self.mkcol(path, options = {}, &block)
    #         route('MKCOL', path, options, &block)
    #     end
    #     #
    #     def self.copy(path, options = {}, &block)
    #         route('COPY', path, options, &block)
    #     end
    #     #
    #   def self.move(path, options = {}, &block)
    #       route('MOVE', path, options, &block)
    #   end
    #   #
    #   def self.propfind(path, options = {}, &block)
    #       route('PROPFIND', path, options, &block)
    #   end
    #   #
    #   def self.proppatch(path, options = {}, &block)
    #       route('PROPPATCH', path, options, &block)
    #   end
    #   # DAV Class 2 Supports
    #   def self.enlock(path, options = {}, &block)
    #       route('LOCK', path, options, &block)
    #   end
    #   #
    #   def self.unlock(path, options = {}, &block)
    #       route('UNLOCK', path, options, &block)
    #   end
    #   # DAV Class 3 Supports
    #   # TODO: Versioning ??
    #   # ### Set OPTIONS Header Values
    #   route('OPTIONS', '*') do
    #       # FIXME no GET on collections, so make this a resource method
    #       headers({"DAV" => "1 2 3", "Ms-Author-Via" => "DAV", "Allow" => "OPTIONS, HEAD, GET, PUT, DELETE, MKCOL, COPY, MOVE, PROPFIND, PROPPATCH, LOCK, UNLOCK"})
    #       ok
    #   end
    # ### Implementation of the verbs:
    get '*' do
        response = GxG::SERVICES[:www][:receiver].handle_request(:get, request, session)
        if response[0] == -255
            send_file(response[2][:result][:file], {:disposition => 'attachment', :filename => File.basename(response[2][:result][:file])})
            GxG::SERVICES[:core][:resources].destroy(response[2][:result][:vfs_dir], ::GxG::DB[:administrator])
            response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
        end
        response
    end
    #
    put '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:put, request, session)
    end
    #
    post '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:post, request, session)
    end
    #
    delete '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:delete, request, session)
    end
    #
    mkcol '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:mkcol, request, session)
    end
    #
    copy '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:copy, request, session)
    end
    #
    move '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:move, request, session)
    end
    #
    propfind '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:propfind, request, session)
    end
    #
    proppatch '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:proppatch, request, session)
    end
    # lock method collision work-around:
    #   lock '*' do
    #       GxG::SERVICES[:www][:receiver].handle_request(:lock, request, session)
    #   end
    route('LOCK', '*') do
        GxG::SERVICES[:www][:receiver].handle_request(:lock, request, session)
    end
    #
    unlock '*' do
        GxG::SERVICES[:www][:receiver].handle_request(:unlock, request, session)
    end
    # Note : options is pre-defined.
end
# ### WebSocket Listener
module GxGwww
    SOCKETS = {}
    SOCKETS_SAFETY = Mutex.new
end
#
class WebSocketListener
    def initialize()
        self
    end
    #
    def on_open(the_socket)
        the_uuid = GxG::uuid_generate.to_sym
        the_socket.instance_variable_set(:@uuid, the_uuid)
        the_socket.instance_variable_set(:@session, nil)
        the_socket.instance_variable_set(:@display, nil)
        the_socket.instance_variable_set(:@inbox, [])
        GxGwww::SOCKETS_SAFETY.synchronize {
            GxGwww::SOCKETS[(the_uuid)] = the_socket
        }
        #
        GxG::SERVICES[:www].dispatcher.post_event(:communications) do
            sleep 0.5
            the_socket.send({ :attach_socket => the_uuid.to_s }.to_json.encode64, :text)
        end
        #
        true
    end
    #
    def on_message(the_socket, the_data, the_type)
        message_queue = the_socket.instance_variable_get(:@inbox)
        GxGwww::SOCKETS_SAFETY.synchronize {
            if the_type == :text
                begin
                    # Expects: json+base64 of a Hash
                    message_queue << JSON.parse(the_data.to_s.decode64, {:symbolize_names => true})
                rescue Exception => the_error
                    log_error({:error => the_error, :parameters => {:data => the_data}})
                end
            else
                # Takes in all other data as binary into inbox
                message_queue << ::GxG::ByteArray.new(the_data.to_s)
            end
        }
        true
    end
    #
    def on_recv(the_socket, the_data, the_type)
        self.on_message(the_socket, the_data, the_type)
    end
    #
    def on_close(the_socket)
        the_uuid = the_socket.instance_variable_get(:@uuid)
        the_session = the_socket.instance_variable_get(:@session)
        the_display = the_socket.instance_variable_get(:@display)
        #
        if the_display
            the_manifest = GxG::SERVICES[:www][:manifests][(the_session)]
            if the_manifest
                if the_manifest.display_exist?(the_display)
                    the_manifest.display_set(the_display, :available)
                    unless the_manifest.connector_get(the_display).remote_closed?
                        the_manifest.connector_get(the_display).close_remote
                    end
                end
            end
        end
        #
        GxGwww::SOCKETS_SAFETY.synchronize {
            GxGwww::SOCKETS.delete(the_uuid)
        }
        puts "Closing Socket #{the_uuid} & Display #{the_display}"
        true
    end
    #
    def on_shutdown()
        puts "Shutdown Received ..."
    end
    #
end
# Load GxGwww:
require (File.expand_path("./www/gxg-www.rb",File.dirname(__FILE__)))
www_service[:manifests] = {}
www_service[:receiver] = GxGwww::Responder.new
# ### Define Public Command Interface:
www_service.on(:start, {:description => "WWW Service Layer Start", :usage => "{ :start => nil }"}) do
  ::GxG::SERVICES[:www].start
end
www_service.on(:stop, {:description => "WWW Service Layer Stop", :usage => "{ :stop => nil }"}) do
  ::GxG::SERVICES[:www].stop
end
www_service.on(:restart, {:description => "WWW Service Layer Restart", :usage => "{ :restart => nil }"}) do
  ::GxG::SERVICES[:www].restart
end
www_service.on(:pause, {:description => "WWW Service Pause", :usage => "{ :pause => nil }"}) do
  ::GxG::SERVICES[:www].pause
end
www_service.on(:resume, {:description => "WWW Service Resume", :usage => "{ :resume => nil }"}) do
  ::GxG::SERVICES[:www].resume
end
# ### Define Internal Service Control Events:
www_service.on(:at_start, {:description => "WWW Startup", :usage => "{ :at_start => (service-object) }"}) do |service, credential|
    #
    # TODO : increment number of threads used in GxG::Engine
    Thread.new { Node0.run! }
    until Node0.running_server do
        sleep 1.0
    end
    (service.configuration[:listen] || []).each_with_index do |the_node, indexer|
      if indexer > 0
          Node0.running_server().listen(the_node[:address],(the_node[:port] || 32767))
          sleep 1.0
          log_info("Also listening on #{the_node[:address]}:#{(the_node[:port] || 32767)} ...")
      end
    end
    # Mount WebSocket Listener
    Node0::running_server.mount_websocket((GxG::SERVICES[:www].configuration[:relative_url].to_s + "/ws"), WebSocketListener.new, "gxg")
    # Load WebDAV Processing:
    # Access files and objects via: GxG::SERVICES[:core][:resources]
    require (File.expand_path("./www/protocols/dav/dav.rb",File.dirname(__FILE__)))
    #
    {:result => true}
end
www_service.on(:at_stop, {:description => "WWW Stop", :usage => "{ :at_stop => (service-object) }", :public => false}) do |service|
    #
    Node0.stop!
    #
    {:result => true}
end
# ### Service Installation
unless ::GxG::Services::service_available?(:www)
    # Set Configuration Defaults
    www_service.configuration[:mode] = "production"
    www_service.configuration[:listen] = [{:address => "127.0.0.1", :port => 32767}]
    www_service.configuration[:relative_url] = ""
    www_service.configuration[:cache_quota] = 1073741824
    www_service.configuration[:cache_max_item_size] = 1073741824
    www_service.save_configuration
    ::GxG::Services::install_service(:www)
    ::GxG::Services::enable_service(:www)
end
#
#