#
federation_service = ::GxG::Services::Service.new(:federation)
federation_service.require_service :core
federation_service.require_service :www
# ### Define Public Command Interface:
federation_service.on(:start, {:description => "Federation Service Layer Start", :usage => "{ :start => nil }"}) do
  ::GxG::SERVICES[:federation].start
end
federation_service.on(:stop, {:description => "Federation Service Layer Stop", :usage => "{ :stop => nil }"}) do
  ::GxG::SERVICES[:federation].stop
end
www_service.on(:restart, {:description => "Federation Service Layer Restart", :usage => "{ :restart => nil }"}) do
  ::GxG::SERVICES[:federation].restart
end
federation_service.on(:pause, {:description => "Federation Service Pause", :usage => "{ :pause => nil }"}) do
  ::GxG::SERVICES[:federation].pause
end
federation_service.on(:resume, {:description => "Federation Service Resume", :usage => "{ :resume => nil }"}) do
  ::GxG::SERVICES[:federation].resume
end
# ### Define Internal Service Control Events:
federation_service.on(:at_start, {:description => "Federation Startup", :usage => "{ :at_start => (service-object) }"}) do |service, credential|
    # ::GxG::GXG_FEDERATION = {:title => "Untitled", :uuid => nil, :available => {}, :connections => {}}
    ::GxG::GXG_FEDERATION_SAFETY.synchronize {
      ::GxG::GXG_FEDERATION[:uuid] = federation_service.configuration[:uuid]
      ::GxG::GXG_FEDERATION[:title] = federation_service.configuration[:title]
    }
    #
    {:result => true}
end
#
federation_service.on(:at_stop, {:description => "Federation Stop", :usage => "{ :at_stop => (service-object) }", :public => false}) do |service|
    #
    
    #
    {:result => true}
end
#
federation_service.on(:connect, {:description => "Federation Connect", :usage => "{ :connect => (uuid) }", :public => false}) do |data|
    #
    if ::GxG::valid_uuid?(data.to_s.to_sym)
      ::GxG::CHANNELS.create_channel(data.to_s.to_sym)
      ::GxG::GXG_FEDERATION_SAFETY.synchronize { {:result => {:uuid => ::GxG::GXG_FEDERATION[:uuid], :title => ::GxG::GXG_FEDERATION[:title]}} }
    else
      {:result => nil}
    end
    #
end
#
federation_service.on(:disconnect, {:description => "Federation Disconnect", :usage => "{ :disconnect => (uuid) }", :public => false}) do |data|
    #
    if ::GxG::valid_uuid?(data.to_s.to_sym)
      ::GxG::CHANNELS.destroy_channel(data.to_s.to_sym)
      {:result => true}
    else
      {:result => false}
    end
    #
end
#
federation_service.on(:operation, {:description => "Perform Operation(s)", :usage => "{ :operation => (Hash/Array) }", :public => false}) do |data|
    # operation(data)
    result = {:result => false}
    if data.is_any?(::Array, ::Hash)
      operations = data
      if operations.is_any?(::Array, ::Hash)
        if operations.is_a?(::Hash)
          operations = [(operations)]
        end
        operations.each_with_index do |operation_frame, op_index|
          if operation_frame.is_a?(::Hash)
            the_operation = operation_frame.keys[0]
            parameters = operation_frame[(the_operation)]
            case the_operation
            when :forward_message
              the_message = parameters.unserialize
              if the_message.is_a?(::GxG::Events::Message)
                channel = ::GxG::CHANNELS.fetch_channel(the_message[:to].to_s.to_sym)
                if channel
                  channel.write(the_message)
                  result = {:result => true}
                else
                  raise Exception.new("Channel #{the_message[:to].inspect} missing--> dropping")
                end
              else
                raise Exception.new("Malformed message payload --> dropping")
              end
            else
              raise Exception.new("The operation #{the_operation.inspect} is not supported.")
            end
          else
            raise Exception.new("You MUST provide a Hash (or Array of Hashes) of serialized data. You passed a #{operation_frame.class.inspect}")
          end
          #
        end
      else
        raise Exception.new("You MUST provide a Hash (or Array of Hashes) of operations. You passed a #{operations.class.inspect}")
      end
    else
      raise Exception.new("You MUST provide a Hash (or Array of Hashes) of operations. You passed a #{data.class.inspect}")
    end
    #
    result
end
#
federation_service.on(:channel_exist, {:description => "Does a channel exist?", :usage => "{ :channel_exist => (uuid) }", :public => false}) do |data|
    # channel_exist(the_uuid)
    if ::GxG::valid_uuid?(data.to_s.to_sym)
      the_channel = ::GxG::CHANNELS.fetch_channel(data.to_s.to_sym)
      if the_channel
        {:result => true}
      else
        {:result => false}
      end
    else
      {:result => false}
    end
    #
end
#
#
federation_service.on(:next_message, {:description => "Get a message", :usage => "{ :next_message => (uuid) }", :public => false}) do |data|
    # next_message(the_uuid)
    if ::GxG::valid_uuid?(data.to_s.to_sym)
      {:result => ::GxG::CHANNELS.next_message(data.to_s.to_sym)}
    else
      {:result => nil}
    end
    #
end
#
federation_service.on(:send_message, {:description => "Send a message", :usage => "{ :send_message => {:uuid => (uuid), :message => (message)} }", :public => false}) do |data|
    # send_message(the_uuid, the_message)
    if ::GxG::valid_uuid?(data[:uuid].to_s.to_sym)
      {:result => ::GxG::CHANNELS.send_message(data[:uuid].to_s.to_sym, data[:message])}
    else
      {:result => false}
    end
    #
end
federation_service.publish_api
# ### Service Installation
unless ::GxG::Services::service_available?(:federation)
    # Set Configuration Defaults
    federation_service.configuration[:title] = "Untitled"
    federation_service.configuration[:uuid] = ::GxG::uuid_generate.to_s
    federation_service.save_configuration
    ::GxG::Services::install_service(:federation)
    ::GxG::Services::enable_service(:federation)
end
#