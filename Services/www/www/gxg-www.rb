#
module GxGwww
    #
    RETAINED = {}
    RETAINED_THREAD_SAFETY = ::Mutex.new
    def self.get_retained(the_key)
        result = nil
        RETAINED_THREAD_SAFETY.synchronize do
            result = ::GxGwww::RETAINED[(the_key)]
        end
        result
    end
    def self.set_retained(the_key, the_value=nil)
        RETAINED_THREAD_SAFETY.synchronize do
            ::GxGwww::RETAINED[(the_key)] = the_value
        end
        the_value
    end
    #
    module Applications
        MENU = []
        def self.refresh_application_menu()
            result = false
            GxGwww::Applications::MENU.clear
            source_queue = ["/Public/www/software/applications"]
            while source_queue.size > 0 do
                the_item = source_queue.shift
                if ::GxG::VFS.exist?(the_item.to_s)
                    profile = ::GxG::VFS.profile(the_item.to_s)
                    if profile.is_a?(::Hash)
                        #
                        if [:virtual_directory, :directory, :persisted_array].include?(profile[:type])
                            ::GxG::VFS.entries(the_item.to_s).each do  |entry|
                                source_queue << (the_item.to_s + "/" + entry[:title])
                            end
                        else
                            #
                            object = GxG::VFS.open(the_item)
                            if object[:component].to_s == "application"
                                record = {:location => (the_item[7..-1]), :application_icon_type => "", :application_icon => "", :application_name => "", :credentialed => false, :unique => true, :category => ""}
                                # TODO: camelize this title text
                                record[:application_name] = object.title.gsub("_"," ")
                                #
                                icon = nil
                                icon_type = nil
                                object[:content].each do |resource|
                                    if resource.title() == "application_icon"
                                        if resource[:options][:image_data]
                                            icon = resource[:options][:image_data]
                                            if icon.is_a?(::GxG::ByteArray)
                                                icon = icon.to_s
                                            end
                                            if resource[:options][:image_type]
                                                icon_type = resource[:options][:image_type]
                                            else
                                                mime_type = ::MimeMagic.by_magic(::StringIO.new(icon.to_s))
                                                if mime_type
                                                    icon_type = mime_type.type
                                                else
                                                    icon_type = "application/octet-stream"
                                                end
                                            end
                                            icon = icon.encode64
                                        else
                                            if resource[:options][:src]
                                                icon = resource[:options][:src]
                                            end
                                        end
                                        if icon
                                            break
                                        end
                                    end
                                end
                                if icon
                                    if icon_type
                                        record[:application_icon_type] = icon_type
                                    end
                                    record[:application_icon] = icon
                                else
                                    cache_entry = GxGwww::CACHE.fetch("/themes/setup/icons/gxg_app.png",GxG::DB[:administrator])
                                    if cache_entry
                                        record[:application_icon_type]  = cache_entry[:content_type]
                                        record[:application_icon] = cache_entry[:data].to_s.encode64
                                    end 
                                end
                                #
                                the_options = (object[:options].unpersist || {})
                                if the_options[:credentialed] == true
                                    record[:credentialed] = true
                                else
                                    record[:credentialed] = false
                                end
                                if the_options[:unique] == true
                                    record[:unique] = true
                                else
                                    record[:unique] = false
                                end
                                record[:category] = (the_options[:category] || "Other")
                                #
                                GxGwww::Applications::MENU << record
                            end
                            #
                        end
                        #
                    end
                end
                #
            end
            result
        end
    end
    #
    module Storage
        class UnifiedMemoryCache
            # ONLY works with GxG::VFS
            # TODO : re-organize to use UniversalResourceAccessor
            # Access files and objects via: GxG::SERVICES[:core][:resources]
            # returns ==> {:token => the_token, :path => the_path, :resource => the_resource}
            def initialize()
                @cache_configuration = {}
                @cache_memory = {}
                @thread_safety = ::Mutex.new
                @cache_configuration[:cache_quota] = (GxG::SERVICES[:www].configuration[:cache_quota] || 1073741824)
                @cache_configuration[:cache_max_item_size] = (GxG::SERVICES[:www].configuration[:cache_max_item_size] || 1073741824)
                #
                self
            end
            #
            def flush_cache()
                @thread_safety.synchronize { @cache_memory = {} }
            end
            #
            def flush_cache_item(specifier=nil)
                if specifier.is_any?(::String, ::Symbol)
                    @thread_safety.synchronize { @cache_memory.delete(specifier.to_s) }
                    true
                else
                    false
                end
            end
            #
            # def public_vfs_fetch(the_vfs_path="", credential=:"00000000-0000-4000-0000-000000000000")
            #     # Does NOT fetch entire directories, only files/db_objects at specific path                
            #     #
            #     log_info("Caching --> #{the_vfs_path}")
            #     result = nil
            #     unless GxG::SERVICES[:core][:resources].busy?(the_vfs_path)
            #         if GxG::SERVICES[:core][:resources].exist?(the_vfs_path)
            #             profile = GxG::SERVICES[:core][:resources].profile(the_vfs_path, credential)
            #             if profile
            #                 case profile[:type]
            #                 when :file, :application, :library, :symlink
            #                     if profile[:size] <= @cache_configuration[:cache_max_item_size]
            #                         handle = GxG::SERVICES[:core][:resources].open(the_vfs_path.to_s, credential)
            #                         if handle
            #                             handle[:resource].rewind
            #                             #
            #                             if (the_vfs_path.to_s[0..10]) == "/Public/www"
            #                                 location = the_vfs_path.to_s[11..-1]
            #                             else
            #                                 location = the_vfs_path.to_s
            #                             end
            #                             #
            #                             buffer = ::GxG::ByteArray.new(handle[:resource].read())
            #                             GxG::SERVICES[:core][:resources].close(handle[:token])
            #                             #
            #                             result = {:location => location, :entry => {:content_type => profile[:mime], :data => buffer.to_s, :uuid => nil, :version => profile[:version], :database => nil, :profile => profile}}
            #                             #
            #                         end
            #                     else
            #                         log_warn "VFS file is too big to load (ignoring): #{the_vfs_path.to_s}"
            #                     end
            #                 when :persisted_hash
            #                     handle = GxG::SERVICES[:core][:resources].open(the_vfs_path.to_s, credential)
            #                     if handle
            #                         uuid = handle[:resource].uuid
            #                         version = handle[:resource].version
            #                         database = handle[:resource].db_address()[:database]
            #                         db_role = self.role_for_database(database)
            #                         # Include format records in gxg_export format
            #                         # This will trade bandwidth + memory for a speed gain later client side hopefully.
            #                         # Review: replace with <db>.sync_export(credential,<uuid-array>).to_json.encode64
            #                         format_records = {}
            #                         object_record = handle[:resource].export
            #                         object_record.search do |item,selector,container|
            #                             if selector == :format || selector == :constraint
            #                                 if item.to_s.size > 0 && ::GxG::valid_uuid?(item.to_s)
            #                                     format_uuid = item
            #                                     unless format_records[(item.to_s.to_sym)].is_a?(::Hash)
            #                                         format_sample = database.format_load({:uuid => format_uuid.to_s.to_sym})
            #                                         format_sample[:content] = format_sample[:content].gxg_export()
            #                                         format_records[(format_uuid.to_s.to_sym)] = format_sample
            #                                     end
            #                                 end
            #                             end
            #                         end
            #                         # buffer = ::GxG::ByteArray.new(::JSON.pretty_generate({:formats => format_records, :record => object_record}).encode64)
            #                         buffer = {:formats => format_records, :record => object_record}.to_json.encode64
            #                         if buffer.size <= @cache_configuration[:cache_max_item_size]
            #                             #
            #                             if (the_vfs_path.to_s[0..10]) == "/Public/www"
            #                                 location = the_vfs_path.to_s[11..-1]
            #                             else
            #                                 location = the_vfs_path.to_s
            #                             end
            #                             #
            #                             # xxx Set Public permissions on db object. (publication speedup)
            #                             # 
            #                             # xxx profile[:permissions][:other] = database.effective_element_permission(handle[:resource].db_address[:table], handle[:resource].db_address[:dbid], :"00000000-0000-4000-0000-000000000000")
            #                             result = {:location => location, :entry => {:content_type => "application/json+base64", :data => buffer.to_s, :uuid => uuid, :version => version, :database => db_role, :profile => profile}}
            #                             #
            #                         else
            #                             log_warn "VFS object is too big to load (ignoring): #{the_vfs_path.to_s}"
            #                         end
            #                         GxG::SERVICES[:core][:resources].close(handle[:token])
            #                     end
            #                 end
            #             end
            #         end
            #     end
            #     result
            # end
            #
            # def add_to_cache(the_vfs_path="")
            #     #
            #     source_queue = []
            #     if the_vfs_path.is_any?(::Array, ::GxG::Database::PersistedArray)
            #         source_list = the_vfs_path
            #     else
            #         source_list = [(the_vfs_path)]
            #     end
            #     source_list.each do |item|
            #         if item.to_s.valid_path?
            #             source_queue << item
            #         end
            #     end
            #     #
            #     while source_queue.size > 0 do
            #         the_item = source_queue.shift
            #         if GxG::SERVICES[:core][:resources].exist?(the_item.to_s)
            #             profile = GxG::SERVICES[:core][:resources].profile(the_item.to_s)
            #             if profile.is_a?(::Hash)
            #                 #
            #                 if [:virtual_directory, :directory, :persisted_array].include?(profile[:type])
            #                     GxG::SERVICES[:core][:resources].entries(the_item.to_s).each do  |entry|
            #                         source_queue << (the_item.to_s + "/" + entry[:title])
            #                     end
            #                 else
            #                     # Cache Item
            #                     current_cache_size = @thread_safety.synchronize { @cache_memory.heap_used() }
            #                     record = self.public_vfs_fetch(the_item)
            #                     if record
            #                         if (record[:entry][:data].size <= @cache_configuration[:cache_max_item_size] && (record[:entry][:data].size + current_cache_size) <= @cache_configuration[:cache_quota])
            #                            # Padrino.cache[(record[:location])] = record[:entry]
            #                             @thread_safety.synchronize { @cache_memory[(record[:location])] = record[:entry] }
            #                         else
            #                             log_warn "VFS item is too big to be cached (ignoring): #{the_item.to_s}"
            #                         end
            #                     end
            #                 end
            #                 #
            #             end
            #         end
            #         #
            #     end
            #     #
            # end
            #
            def fetch_by_uuid(the_uuid=nil, credential=nil, auto_cache=true,search_only=false)
                result = nil
                # Search Cache first for matching entry
                the_object = nil
                found = nil
                from_cache = false
                unless search_only
                     @thread_safety.synchronize do
                         @cache_memory.keys.each do |the_key|
                             if @cache_memory[(the_key)][:uuid].to_s.to_sym == the_uuid.to_sym
                                 found = @cache_memory[(the_key)]
                                 from_cache = true
                                 break
                             end
                         end
                     end
                end
                # Then search each db by role for the object with the uuid (slow)
                unless found
                    already_searched = []
                    GxG::DB[:roles].keys.each do |the_db_role|
                       the_db = GxG::DB[:roles][(the_db_role)]
                       unless already_searched.index(the_db)
                           already_searched << the_db
                           the_object = the_db.retrieve_by_uuid(the_uuid,credential)
                           if the_object.is_a?(::GxG::Database::PersistedHash)
                               break
                           else
                               the_object = nil
                           end
                       end
                       #
                    end
                    #
                    if the_object
                        # prepare into Cache entry
                        uuid = the_object.uuid
                        version = the_object.version
                        database = the_object.db_address()[:database]
                        db_role = self.role_for_database(database)
                        # Include format records in gxg_export format
                        format_records = {}
                        object_record = the_object.export
                        object_record.search do |item,selector,container|
                            if selector == :format || selector == :constraint
                                if item.to_s.size > 0
                                    format_uuid = item
                                    unless format_records[(item.to_s.to_sym)].is_a?(::Hash)
                                        format_sample = database.format_load({:uuid => format_uuid.to_s.to_sym})
                                        format_sample[:content] = format_sample[:content].gxg_export()
                                        format_records[(format_uuid.to_s.to_sym)] = format_sample
                                    end
                                end
                            end
                        end
                        # buffer = ::GxG::ByteArray.new(::JSON.pretty_generate({:formats => format_records, :record => object_record}).encode64)
                        buffer = {:formats => format_records, :records => [(object_record)]}.to_json.encode64
                        if buffer.size <= @cache_configuration[:cache_max_item_size]
                            # Set Public permissions on db object. (publication speedup)
                            # 
                            profile = {:title=> the_object.title, :type=>:persisted_hash, :owner_type=>:persisted_hash, :uuid=>uuid, :on_device=>nil, :on_device_major=>nil, :on_device_minor=>nil, :is_device=>nil, :is_device_major=>nil, :is_device_minor=>nil, :inode=>nil, :flags=>[:read], :hardlinks_to=>0, :user_id=>nil, :group_id=>nil, :size=>0, :block_size=>0, :blocks=>0, :accessed=>nil, :modified=>nil, :status_modified=>nil, :permissions=>{:effective=>{:execute=>false, :rename=>true, :move=>true, :destroy=>true, :create=>true, :write=>true, :read=>true}}, :mode=>nil}
                            profile[:permissions][:effective] = database.effective_element_permission(the_object.db_address[:table], the_object.db_address[:dbid], credential.to_s.to_sym)
                            #
                            profile[:permissions][:other] = database.effective_element_permission(the_object.db_address[:table], the_object.db_address[:dbid], :"00000000-0000-4000-0000-000000000000")
                            found = {:content_type => "application/json+base64", :data => buffer.to_s, :uuid => uuid, :version => version, :database => db_role, :profile => profile}
                            #
                        end
                        the_object.deactivate
                    end
                end
                # Cache if auto_cache=true
                if found
                    unless from_cache
                        if auto_cache
                            @thread_safety.synchronize do
                                @cache_memory[(the_uuid.to_s)] = found
                            end
                        end
                    end
                    result = found
                end
                result
            end
            #
            def role_for_database(the_db=nil)
                result = :vfs
                GxG::DB[:roles].keys.each do |the_db_role|
                    if the_db == GxG::DB[:roles][(the_db_role)]
                        result = the_db_role
                        break
                    end
                end
                result
            end
            #
            def database_by_role(the_role=nil)
                result = nil
                GxG::DB[:roles].keys.each do |the_db_role|
                    if the_role == the_db_role
                        result = GxG::DB[:roles][(the_db_role)]
                        break
                    end
                end
                result
            end
            #
            def update_cache_item(the_vfs_path="")
                # Customizable later:
                if ::GxG::valid_uuid?(the_vfs_path)
                    # This is kinda crack-monkey, but it will only search dbs for a fresh copy of the object and add it to Cache.
                    self.fetch_by_uuid(the_vfs_path, GxG::DB[:administrator], true, true)
                else
                    self.add_to_cache(the_vfs_path)
                end
                true
            end
            #
            def fetch(the_location="",credential=:"00000000-0000-4000-0000-000000000000",auto_cache=true)
                result = nil
                fits_in_cache = true
                #
                if auto_cache == true
                    @thread_safety.synchronize {
                        result = @cache_memory[(the_location.to_s)]
                    }
                end
                unless result.is_a?(::Hash)
                    if ::GxG::valid_uuid?(the_location.to_s)
                        # DB Object
                        result = self.fetch_by_uuid(the_location.to_s, credential, false, false)
                    else
                        # File or DB Object in VFS
                        handle = ::GxG::SERVICES[:core][:resources].open(the_location.to_s, credential)
                        #
                        profile = ::GxG::SERVICES[:core][:resources].profile(the_location.to_s, credential)
                        #
                        if handle.is_a?(::Hash) && profile.is_a?(::Hash)
                            if handle[:resource].is_a?(::GxG::Database::PersistedHash)
                                # DB Object
                                uuid = handle[:resource].uuid
                                version = handle[:resource].version
                                database = handle[:resource].db_address()[:database]
                                db_role = self.role_for_database(database)
                                # Include format records in gxg_export format
                                format_records = {}
                                object_record = handle[:resource].export
                                object_record.search do |item,selector,container|
                                    if selector == :format || selector == :constraint
                                        if item.to_s.size > 0
                                            format_uuid = item
                                            unless format_records[(item.to_s.to_sym)].is_a?(::Hash)
                                                format_sample = database.format_load({:uuid => format_uuid.to_s.to_sym})
                                                if format_sample.is_a?(::Hash)
                                                    format_sample[:content] = format_sample[:content].gxg_export()
                                                    format_records[(format_uuid.to_s.to_sym)] = format_sample
                                                end
                                            end
                                        end
                                    end
                                end
                                # buffer = ::GxG::ByteArray.new(::JSON.pretty_generate({:formats => format_records, :record => object_record}).encode64)
                                buffer = {:formats => format_records, :records => [(object_record)]}.to_json.encode64
                                result = {:content_type => "application/json+base64", :data => buffer.to_s, :uuid => uuid, :version => version, :database => db_role, :profile => profile}
                                unless buffer.size <= @cache_configuration[:cache_max_item_size]
                                    fits_in_cache = false
                                    log_warn("Item TOO BIG for CACHE : #{buffer.size} for #{handle[:path]}")
                                end
                            else
                                # File Object
                                if handle[:resource].is_a?(::File)
                                    handle[:resource].rewind
                                    buffer = ::GxG::ByteArray.new(handle[:resource].read().to_s)
                                    result = {:content_type => profile[:mime], :data => buffer.to_s, :uuid => nil, :version => profile[:version], :database => nil, :profile => profile}
                                    unless buffer.size <= @cache_configuration[:cache_max_item_size]
                                        fits_in_cache = false
                                        log_warn("Item TOO BIG for CACHE : #{buffer.size} for #{handle[:path]}")
                                    end
                                end
                            end
                            #
                            ::GxG::SERVICES[:core][:resources].close(handle[:token])
                        end
                    end
                    if result.is_a?(::Hash)
                        if auto_cache == true && fits_in_cache == true
                            # Store in CACHE
                            @thread_safety.synchronize {
                                @cache_memory[(the_location.to_s)] = result
                            }
                        end
                    end
                end
                #
                result
            end
        end
    end
    # DisplayState
    class Display
        def initialize(settings={})
            @resource_path = settings[:resource]
            @session = settings[:session]
            @uuid = (settings[:uuid] || GxG::uuid_generate)
            @remote_uuid = nil
            @socket = nil
            self
        end
        #
        def socket()
            @socket
        end
        #
        def set_socket(the_uuid)
            the_socket = nil
            GxGwww::SOCKETS_SAFETY.synchronize {
                the_socket = GxGwww::SOCKETS[(the_uuid)]
                if the_socket
                    the_socket.instance_variable_set(:@session, @session)
                    the_socket.instance_variable_set(:@display, @uuid)
                end
            }
            if the_socket
                @socket = the_socket
                true
            else
                false
            end
        end
    end
    #
    class Manifest
        def initialize(settings={})
            @thread_safety = ::Mutex.new
            @credential = (settings[:credential] || :"00000000-0000-4000-0000-000000000000")
            @displays ={}
            @connectors = {}
            @timers = {}
            @state = :uncredentialed
            self
        end
        #
        def credential_set(the_credential=:"00000000-0000-4000-0000-000000000000")
            if the_credential
                @thread_safety.synchronize {
                     @credential = the_credential
                }
            end
        end
        #
        def credential_get()
            the_credential = :"00000000-0000-4000-0000-000000000000"
            @thread_safety.synchronize {
                the_credential = @credential
            }
            the_credential
        end
        #
        def display_count()
            the_count = 0
            @thread_safety.synchronize {
                the_count = @displays.keys.size
            }
            the_count
        end
        #
        def display_keys()
            the_keys = []
            @thread_safety.synchronize {
                the_keys = @displays.keys
            }
            the_keys
        end
        #
        def display_exist?(the_display_key=nil)
            result = false
            if the_display_key
                @thread_safety.synchronize {
                    if @displays[(the_display_key)]
                        result = true
                    end
                }
            end
            result
        end
        #
        def display_get(the_display_key=nil)
            result = :available
            if the_display_key
                @thread_safety.synchronize {
                    result = @displays[(the_display_key)]
                }
            end
            result
        end
        #
        def display_set(the_display_key=nil, the_value=:available)
            result = nil
            if the_display_key
                @thread_safety.synchronize {
                    @displays[(the_display_key)] = the_value
                }
            end
            result
        end
        #
        def state_set(the_state=:none)
            @thread_safety.synchronize {
                @state = the_state
            }
        end
        #
        def state_get()
            the_state = :none
            @thread_safety.synchronize {
                the_state = @state
            }
            the_state
        end
        #
        def timer_get(the_display_key=nil)
            result = nil
            if the_display_key
                @thread_safety.synchronize {
                    result = @timers[(the_display_key)]
                }
            end
            result
        end
        #
        def timer_set(the_display_key=nil, timeout=0.0)
            if the_display_key
                @thread_safety.synchronize {
                    @timers[(the_display_key)] = timeout
                }
                timeout
            else
                nil
            end
        end
        #
        def connector_get(the_display_key=nil)
            result = nil
            if the_display_key
                @thread_safety.synchronize {
                    result = @connectors[(the_display_key)]
                }
            end
            result
        end
        #
        def connector_set(the_display_key=nil, the_connector=nil)
            if the_display_key && the_connector
                @thread_safety.synchronize {
                    @connectors[(the_display_key)] = the_connector
                }
            end
        end
    end
    # ---------------------------------------------------------------------
    class Responder
        #
        def initialize(options={})
            @thread_safety = ::Mutex.new
        end
        #
        def handle_request(the_method=nil, the_request=nil, the_session=nil)
            response = [404, {"content-type" => "application/text"}, "Not Found"]
            begin
                response[2] =  "#{the_request.path} Not Found"
                if the_request.xhr?
                    the_manifest = GxG::SERVICES[:www][:manifests][(the_session['session_id'])]
                    unless the_manifest
                        the_manifest = ::GxGwww::Manifest.new({:credential => :'00000000-0000-4000-0000-000000000000'})
                        # manifest format: {:credential => :'00000000-0000-4000-0000-000000000000', :displays => {}, :timers => {}, :connectors => {}, :status => :none}
                        GxG::SERVICES[:www][:manifests][(the_session['session_id'])] = the_manifest
                    end
                    # the_display = (the_request.params["display_path"] || the_request.env["GxG-Display"])
                    the_display = the_request.params["display"]
                    if the_display.is_a?(::String)
                        if the_display.match(/\/display\/[0-9]/) || the_display.match(/\/display\/[0-9][0-9]/)
                            if the_manifest
                                if the_manifest.display_count() > 0
                                    unless (the_display.split("/").last.to_i + 1) <= the_manifest.display_count()
                                        log_warn "Invalid Display Reference: #{the_display.inspect}"
                                    end
                                end
                            end
                        else
                            the_display = nil
                        end
                    else
                        the_display = nil
                    end
                    #
                    operations = []
                    case the_method
                    when :get
                        if the_request.params["details"].to_s.size > 0
                            operations = (::JSON::parse(URI.unescape(URI.unescape(the_request.params["details"].to_s.decode64)), {:symbolize_names => true}))
                        end
                    when :put
                        if the_request.body.respond_to?(:rewind) && the_request.body.respond_to?(:read)
                             the_request.body.rewind
                             operations = (::JSON::parse(URI.unescape(URI.unescape(the_request.body.read())), {:symbolize_names => true}))
                        else
                            log_warn("Abnormal PUT Body #{the_request.body.inspect}")
                        end
                    when :post
                        #
                        if the_request.params["file"]
                            if the_request.params["file"][:tempfile]
                                temp_file = the_request.params["file"][:tempfile]
                                if the_request.params["file"][:filename]
                                    file_name  = the_request.params["file"][:filename]
                                    if the_request.params["destination"]
                                        destination = the_request.params["destination"]
                                        operations = [{:upload_file => {:temp_file => temp_file, :file_name => file_name, :destination => destination}}]
                                    end
                                end
                            end
                            #
                        end
                        #
                    end
                    unless operations.is_a?(::Array)
                        operations = [(operations)]
                    end
                    operations.each do |operation_frame|
                        if operation_frame.is_a?(::Hash)
                            the_operation = operation_frame.keys[0]
                            parameters = operation_frame[(the_operation)]
                            # Review : DEBUG:
                            puts "Operation: #{the_operation.inspect} => #{parameters.inspect}"
                            puts "Remote Host: #{the_request.env["HTTP_X_FORWARDED_FOR"].inspect}"
                            puts "Session: #{the_session['session_id'].inspect}"
                            #
                            case the_operation
                            when :heartbeat
                                # use display_path? reset timer info?
                                # pass server/credential status:  :private or :public indicators only
                                if the_manifest.credential_get() == :"00000000-0000-4000-0000-000000000000"
                                    status = {:status => "uncredentialed"}
                                    status[:credential] = (the_manifest.state_get() || :uncredentialed)
                                else
                                    status = {:status => "credentialed"}
                                    status[:credential] = (the_manifest.state_get() || :credentialed)
                                end
                                if true
                                    # TODO: track and return the running mode of the server - Expansion
                                    status[:server] = :running
                                else
                                    status[:server] = :maintainence
                                end
                                if the_display
                                    the_manifest.timer_set(the_display, ::Chronic::parse("in 3 minutes").to_f)
                                end
                                #
                                response = [200, {"content-type" => "application/json"}, {:result => status}.to_json()]
                                break
                                #
                            when :attach_socket
                                if the_display
                                    the_uuid = parameters.to_s.to_sym
                                    if ::GxG::valid_uuid?(the_uuid)
                                        GxGwww::SOCKETS_SAFETY.synchronize {
                                            GxGwww::SOCKETS[(the_uuid)].instance_variable_set(:@session, the_session['session_id'])
                                            GxGwww::SOCKETS[(the_uuid)].instance_variable_set(:@display, the_display)
                                        }
                                        if GxG::SERVICES[:www][:manifests][(the_session['session_id'])]
                                            connector = GxG::SERVICES[:www][:manifests][(the_session['session_id'])].connector_get(the_display)
                                            if connector
                                                connector.set_socket_uuid(the_uuid)
                                            else
                                                raise Exception, "Connector Not Found."
                                            end
                                        else
                                            raise Exception, "Manifest Not Found For Session."
                                        end
                                        puts "Websocket Attached: #{the_uuid.inspect}"
                                        response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                                        break
                                    end
                                end
                                # Review : TODO: more follow up on internal socket messaging system
                                #
                            when :close
                                if the_display
                                    if the_manifest.display_exist?(the_display)
                                        the_manifest.display_set(the_display, :available)
                                        unless the_manifest.connector_get(the_display).remote_closed?
                                            the_manifest.connector_get(the_display).close_remote
                                        end
                                    end
                                    response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                                    break
                                end
                            when :introduction
                                # puts "Introduction Display: #{the_display.inspect}"
                                connection_uuid = nil
                                remote_uuid = parameters.to_s.to_sym
                                unless ::GxG::valid_uuid?(remote_uuid.to_s)
                                    raise "Invalid Remote ID."
                                end
                                # xxx
                                unless the_display
                                    # Expire old Displays and set to :available
                                    the_manifest.display_keys.each do |display_key|
                                        if the_manifest.timer_get(display_key).is_a?(::Numeric)
                                            if Time.now.to_f > the_manifest.timer_get(display_key)
                                                the_manifest.display_set(display_key, :available)
                                                connector = the_manifest.connector_get(display_key)
                                                if connector
                                                    unless connector.remote_closed?
                                                        connector.close_remote
                                                    end
                                                end
                                            end
                                        else
                                            the_manifest.timer_set(display_key, ::Chronic::parse("in 3 minutes").to_f)
                                            the_manifest.display_set(display_key, :available)
                                            connector = the_manifest.connector_get(display_key)
                                            if connector
                                                unless connector.remote_closed?
                                                    connector.close_remote
                                                end
                                            end
                                        end
                                    end
                                    # Find available Display
                                    the_manifest.display_keys.each do |display_key|
                                        if the_manifest.display_get(display_key) == :available
                                            the_manifest.display_set(display_key, :in_use)
                                            the_manifest.timer_set(display_key, ::Chronic::parse("in 3 minutes").to_f)
                                            connector = the_manifest.connector_get(display_key)
                                            if connector
                                                # re-open Connector
                                                connector.open_remote(remote_uuid)
                                            else
                                                # puts "Connector Created."
                                                # create Connector
                                                connector_settings = {
                                                    :display => display_key,
                                                    :session_id => the_session['session_id'],
                                                    :remote_uuid => remote_uuid,
                                                    :credential => the_manifest.credential_get(),
                                                    :credential_status => :running
                                                }
                                                #
                                                the_manifest.connector_set(display_key, ::GxGwww::Connector.new(connector_settings))
                                                # Review: what are all the session-wide manifest states possible?
                                                the_manifest.state_set(:running)
                                            end
                                            the_display = display_key
                                            connection_uuid = connector.uuid()
                                            break
                                        end
                                    end
                                    # Add Display if needed
                                    unless the_display
                                        the_display = ("/display/" << the_manifest.display_count.to_s)
                                        the_manifest.display_set(the_display, :in_use)
                                        the_manifest.timer_set(the_display, ::Chronic::parse("in 3 minutes").to_f)
                                        connector_settings = {
                                            :display => the_display,
                                            :session_id => the_session['session_id'],
                                            :remote_uuid => remote_uuid,
                                            :credential => the_manifest.credential_get(),
                                            :credential_status => :running
                                        }
                                        connector = ::GxGwww::Connector.new(connector_settings)
                                        # puts "Connector Created - 2nd Portion."
                                        the_manifest.connector_set(the_display, connector)
                                        connection_uuid = connector.uuid()
                                    end
                                end
                                unless connection_uuid
                                    connector = the_manifest.connector_get(the_display)
                                    if connector
                                        connection_uuid = connector.uuid()
                                    end
                                end
                                #
                                if the_manifest.credential_get() == :"00000000-0000-4000-0000-000000000000"
                                    current_status = "uncredentialed"
                                else
                                    current_status = "credentialed"
                                end
                                #
                                response = [200, {"content-type" => "application/json"}, {:result => "OK", :csrf => the_session["csrf"], :display => the_display, :relative_url => GxG::SERVICES[:www].configuration[:relative_url], :remote_uuid => connection_uuid.to_s, :status => current_status}.to_json()]
                                #
                                break
                            when :downgrade_credential
                                the_manifest.state_set(:exiting)
                                the_manifest.display_keys.each do |display_key|
                                    if the_manifest.connector_get(display_key)
                                        the_manifest.connector_get(display_key).update_credential_status(the_manifest.state_get())
                                    end
                                end
                                #
                                # manifest[:connectors][(the_display)].update_credential_status(status[:credential])
                                # check if the connectors are 'exitready'
                                if the_manifest.state_get() == :exiting
                                    readyflag = true
                                    the_manifest.display_keys.each do |display_key|
                                        if the_manifest.connector_get(display_key)
                                            unless the_manifest.connector_get(display_key).exitready?
                                                readyflag = false
                                            end
                                        end
                                    end
                                    if readyflag == true
                                        the_manifest.credential_set(:"00000000-0000-4000-0000-000000000000")
                                        the_manifest.state_set(:uncredentialed)
                                        the_manifest.display_keys.each do |display_key|
                                            connector = the_manifest.connector_get(display_key)
                                            if connector
                                                connector.update_credential(:"00000000-0000-4000-0000-000000000000")
                                                connector.update_credential_status(the_manifest.state_get())
                                            end
                                        end
                                    end
                                end
                                #
                                response = [200, {"content-type" => "application/json"}, {:status => "uncredentialed"}.to_json()]
                                #
                                break
                            when :update_credential
                                response = [404, {"content-type" => "application/json"}, {:status => "Not Found"}.to_json()]
                                if parameters.base64?
                                    parameters = parameters.decode64
                                end
                                parameters = parameters.decrypt(the_session["csrf"].to_s)
                                if parameters.json?
                                    parameters = ::JSON::parse(parameters, {:symbolize_names => true})
                                    new_credential = GxG::DB[:authority].user_credential(parameters[:user].to_s, parameters[:password].to_s)
                                    if new_credential.is_any?(::String, ::Symbol)
                                        the_manifest.credential_set(new_credential.to_s.to_sym)
                                        # update connector credentials
                                        the_manifest.display_keys.each do |display_key|
                                            the_connector = the_manifest.connector_get(display_key)
                                            if the_connector
                                                the_connector.update_credential(new_credential.to_s.to_sym)
                                            end
                                        end
                                        response = [200, {"content-type" => "application/json"}, {:status => "credentialed"}.to_json()]
                                        #
                                        break
                                    else
                                        # Failed login attempt
                                        log_warn("Failed login attempt with: #{parameters.inspect}")
                                    end
                                else
                                    # Hack attempt maybe? Malformed certainly.
                                    log_warn("Malformed payload on login attempt with: #{parameters.inspect}")
                                end
                                #
                            else
                                # Review : dispatch the_operation (operations not baked-in toward session/sockets) to the connector
                                if the_display
                                    the_manifest.timer_set(the_display, ::Chronic::parse("in 3 minutes").to_f)
                                    connector = the_manifest.connector_get(the_display)
                                    if connector
                                        if connector.respond_to?(the_operation)
                                            if parameters
                                                response = connector.send(the_operation, parameters)
                                            else
                                                response = connector.send(the_operation)
                                            end
                                        end
                                    end
                                end
                                #
                            end
                            # end the_operation case
                        end
                    end
                    # end .xhr?
                else
                    # TODO : check for websocket here and place on the right display object/connector.
                   # Standard request
                   # Strip BASEURL if present
                   if GxG::SERVICES[:www].configuration[:relative_url].size > 0
                        request_path = the_request.path[((GxG::SERVICES[:www].configuration[:relative_url].size)..-1)]
                   else
                        request_path = the_request.path
                   end
                   #
                   # puts "Got Request Path: #{request_path}"
                   # ????
                   case the_method
                   when :get
                       if ["", "/", "/index"].include?(request_path) || ::GxG::SERVICES[:core][:resources].exist?("/Public/www/content/pages#{request_path}")
                           # Send bootstrap html page and wait for xhr requests
                           # content = GxGwww::CACHE.fetch("/page.html",the_session[:credential])
                           response[0] = 200
                           # response[1]["content-type"] = content[:content_type]
                           response[1]["content-type"] = "text/html"
                           # response[2] = content[:data]
                           response[2] = self.default_page_content()
                       else
                           # Asset :get request
                           if ::GxG::SERVICES[:core][:resources].exist?(("/Public/www" << request_path))
                            content = GxGwww::CACHE.fetch(("/Public/www" << request_path), (the_session[:credential] || :"00000000-0000-4000-0000-000000000000"), true)
                            if content
                                response[0] = 200
                                response[1]["content-type"] = content[:content_type]
                                response[1]["X-Content-Type-Options"] = "nosniff"
                                response[2] = content[:data]
                            else
                                 log_warn "Failed to fetch: #{request_path}"
                            end
                           end
                       end
                   when :put
                   when :post
                        #                       if the_request.path.include?("/display/")
                        #                           if the_request.params["operation"] == "close"
                        #                               puts "Close Attempt on #{the_request.path}"
                        #                           end
                        #                       end
                   when :delete
                   end
                end
            rescue Exception => the_error
                log_error({:error => the_error, :parameters => {:method => the_method, :request => the_request, :session => the_session}})
                response = [500, {"content-type" => "application/text"}, "Error"]
            end
           #
           response
        end
        #
        def default_page_content()
            result = ""
            #
            result << "<html>\n"
            result << "\t<head>\n"
            result << "\t\t<meta charset=\"utf-8\">\n"
            result << "\t\t<meta http-equiv=\"x-ua-compatible\" content=\"ie=edge\">\n"
            result << "\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
            # result << ("\t\t<link rel=\"stylesheet\" href=\"http://fonts.googleapis.com/css?family=Varela\">\n")
            result << ("\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/themes/foundation.css\">\n")
            # result << ("\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"" + $GxG::SERVICES[:www].configuration[:relative_url].to_s + "/themes/app.css\">\n")
            result << ("\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/themes/page.css\">\n")
            result << "\t</head>\n"
            result << "\t<body>\n"
            result << ("\t\t<script id=\"jquery\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/vendor/jquery.js\"></script>\n")
            result << ("\t\t<script id=\"what.input\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/vendor/what-input.js\"></script>\n")
            result << ("\t\t<script id=\"foundation\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/vendor/foundation.js\"></script>\n")
            result << ("\t\t<script>$(document).foundation();</script>\n")
            result << ("\t\t<script id=\"kute.animation\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/kute/kute.min.js\"></script>\n")
            result << ("\t\t<script id=\"kute.attr\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/kute/kute-attr.min.js\"></script>\n")
            result << ("\t\t<script id=\"kute.css\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/kute/kute-css.min.js\"></script>\n")
            result << ("\t\t<script id=\"kute.text\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/kute/kute-text.min.js\"></script>\n")
            result << ("\t\t<script id=\"kute.svg\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/kute/kute-svg.min.js\"></script>\n")
            result << ("\t\t<script id=\"gxg\" type=\"text/javascript\" src=\"" + GxG::SERVICES[:www].configuration[:relative_url].to_s + "/javascript/gxg.js\"></script>\n")
            result << "\t</body>\n"
            result << "</html>"
            #
            result
        end
        #
    end
    #
    class Connector
        #
        def initialize(settings={})
            @uuid = ::GxG::uuid_generate().to_sym
            @remote_uuid = settings[:remote_uuid].to_s.to_sym
            @credential = settings[:credential]
            @credential_status = settings[:credential_status]
            @active = true
            @application_states = []
            @display = settings[:display]
            @session_id = settings[:session_id]
            @socket = nil
            # ????
            self
        end
        #
        def socket_uuid()
            @socket
        end
        #
        def uuid()
            @uuid
        end
        def update_credential(the_credential=nil)
            if ::GxG::valid_uuid?(the_credential.to_s)
                @credential = the_credential.to_s.to_sym
            end
            true
        end
        #
        def update_credential_status(credential_status)
            @credential_status = credential_status
        end
        #
        def exitready?()
            # When all applications acknowledge exiting status and set 'exitready' THEN downgrade the credential and return true.
            exitready = true
            @application_states.each do |the_record|
                unless the_record[:status] == 'exitready'
                    exitready = false
                    break
                end
            end
            exitready
        end
        #
        def inspect()
            "<Connector: :uuid => #{@uuid.inspect}, :remote_uuid => #{@remote_uuid.inspect}>"
        end
        #
        def open_remote(remote_uuid=nil)
            if remote_uuid
                @remote_uuid = remote_uuid.to_s.to_sym
                @active = true
            end
        end
        #
        def close_remote()
            @remote_uuid = nil
            @active = false
        end
        #
        def remote_closed?
            if @remote_uuid
                false
            else
                true
            end
        end
        #
        def close()
            close_remote
        end
        #
        def closed?
           ! @active
        end
        # ---------------------------------------------
        # Callable Toolbox
        def set_socket_uuid(the_uuid)
            @socket = the_uuid
        end
        #
        def admin_get_roles()
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:administrators], @credential)
                    response = [200, {"content-type" => "application/json"}, ({:result => GxG::DB[:authority].role_manifest()}).to_json]
                else
                    # err - Hack attempt ??
                    response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => false}).to_json()]
                end
            end
            response
        end
        #
        def call_event(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                the_service = ::GxG::SERVICES[(details[:service].to_s.downcase.to_sym)]
                if the_service
                    the_result = the_service.call_event(details[:op_frame], @credential)
                    if the_result[:error]
                        response = [500, {"content-type" => "application/json"}, ({:result => false, :error => the_result[:error], :parameters => false}).to_json()]
                    else
                        response = [200, {"content-type" => "application/json"}, (the_result.to_json]
                    end
                else
                    # err - service not found
                    response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Service #{details[:service].to_s} Not Found.", :parameters => false}).to_json()]
                end
            end
            response
        end
        #
        def upload_file(details={})
            response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Unknown Error."}).to_json()]
            # {:temp_file => temp_file, :file_name => file_name, :destination => destination}
            begin
                temp_dir = "/Temporary/#{::GxG::uuid_generate().to_s}"
                download_path = "#{temp_dir + "/" + (details[:file_name] || "Untitled").to_s}"
                final_path =  "#{details[:destination].to_s + "/" + (details[:file_name] || "Untitled").to_s}"
                GxG::SERVICES[:core][:resources].create_directory(temp_dir, ::GxG::DB[:administrator])
                GxG::SERVICES[:core][:resources].create(download_path, ::GxG::DB[:administrator])
                handle = GxG::SERVICES[:core][:resources].open_writable(download_path, ::GxG::DB[:administrator])
                handle[:resource].write details[:temp_file].read
                GxG::SERVICES[:core][:resources].close(handle[:token])
                GxG::SERVICES[:core][:resources].move(download_path, ::GxG::DB[:administrator], final_path)
                GxG::SERVICES[:core][:resources].set_permissions(final_path, @credential, {:execute => false, :rename => true, :move => true, :destroy => true, :create => true, :write => true, :read=>true})
                # 
                response = [200, {"content-type" => "application/json"}, ({:result => true}).to_json()]
            rescue Exception => the_error
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => the_error.to_s}).to_json()]
            end
            response
        end
        #
        def vfs_mkfile(details={})
            # Review : find correct cooresponding return codes for errors.
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details.is_a?(::Hash)
                    the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s).gsub("//","/")
                    if GxG::SERVICES[:core][:resources].exist?(the_path)
                        response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Already Exists.", :parameters => details}).to_json()]
                    else
                        dir_profile = GxG::SERVICES[:core][:resources].profile(::File.dirname(the_path),@credential)
                        if dir_profile.is_a?(::Hash)
                            if dir_profile[:permissions][:effective][:create] == true
                                if details[:format]
                                    result = GxG::SERVICES[:core][:resources].create(the_path, @credential, {:format => details[:format]})
                                else
                                    result = GxG::SERVICES[:core][:resources].create(the_path, @credential)
                                end
                                response = [200, {"content-type" => "application/json"}, result.to_json()]
                            else
                                # err - Hack attempt ?? (user app SHOULD pre-screen!)
                                response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => false}).to_json()]
                            end
                        else
                            response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Profile.", :parameters => details}).to_json()]
                        end
                    end
                    #
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Parameter.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def vfs_mkdir(details={})
            # Review : find correct cooresponding return codes for errors.
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details.is_a?(::Hash)
                    the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s).gsub("//","/")
                    if GxG::SERVICES[:core][:resources].exist?(the_path)
                        response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Already Exists.", :parameters => details}).to_json()]
                    else
                        dir_profile = GxG::SERVICES[:core][:resources].profile(::File.dirname(the_path),@credential)
                        if dir_profile.is_a?(::Hash)
                            if dir_profile[:permissions][:effective][:create] == true
                                response = [200, {"content-type" => "application/json"}, GxG::SERVICES[:core][:resources].create_directory(the_path, @credential).to_json()]
                            else
                                # err - Hack attempt ?? (user app SHOULD pre-screen!)
                                response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => false}).to_json()]
                            end
                        else
                            response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Profile.", :parameters => details}).to_json()]
                        end
                    end
                    #
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Parameter.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def vfs_rename(details={})
            # Review : find correct cooresponding return codes for errors.
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details.is_a?(::Hash)
                    error_response = nil
                    unless details[:path].to_s.size > 0
                        error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Path.", :parameters => details}).to_json()]
                    end
                    unless details[:new_name].to_s.size > 0
                        error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "New Name Not Specified.", :parameters => details}).to_json()]
                    end
                    if error_response
                        response = error_response
                    else
                        prefix = GxG::SERVICES[:core][:resources].home_path(@credential).to_s
                        container = (prefix + "/" + File.dirname(details[:path].to_s)).gsub("//","/")
                        the_path = (prefix + "/" + details[:path].to_s).gsub("//","/")
                        if GxG::SERVICES[:core][:resources].exist?((container + "/" + details[:new_name].to_s).gsub("//","/"))
                            response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Already Exists.", :parameters => details}).to_json()]
                        else
                            the_profile = GxG::SERVICES[:core][:resources].profile(the_path,@credential)
                            if the_profile.is_a?(::Hash)
                                if the_profile[:permissions][:effective][:rename] == true
                                    result = GxG::SERVICES[:core][:resources].rename(the_path, @credential, details[:new_name].to_s)
                                    if result[:result] == true
                                        response = [200, {"content-type" => "application/json"}, GxG::SERVICES[:core][:resources].rename(the_path, @credential, details[:new_name].to_s).to_json()]
                                        #
                                    else
                                        response = [403, {"content-type" => "application/json"}, result.to_json()]
                                    end
                                else
                                    # err - Hack attempt ?? (user app SHOULD pre-screen!)
                                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Permission Error.", :parameters => false}).to_json()]
                                end
                            else
                                response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Input.", :parameters => details}).to_json()]
                            end
                        end
                        #
                    end
                    #
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Parameter.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def vfs_destroy(detials={})
            # Review : find correct cooresponding return codes for errors.
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details.is_a?(::Hash)
                    the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s).gsub("//","/")
                    if GxG::SERVICES[:core][:resources].exist?(the_path)
                        the_profile = GxG::SERVICES[:core][:resources].profile(the_path, @credential)
                        if the_profile.is_a?(::Hash)
                            if the_profile[:permissions][:effective][:destroy] == true
                                result = GxG::SERVICES[:core][:resources].destroy(the_path, @credential)
                                if result[:result] == true
                                    response = [200, {"content-type" => "application/json"}, result.to_json()]
                                else
                                    response = [403, {"content-type" => "application/json"}, result.to_json()]
                                end
                            else
                                # err - Hack attempt ?? (user app SHOULD pre-screen!)
                                response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => false}).to_json()]
                            end
                        else
                            response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Profile.", :parameters => details}).to_json()]
                        end
                    else
                        response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => details}).to_json()]
                    end
                    #
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Malformed Parameter.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def vfs_copy(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                error_response = nil
                unless details[:source].to_s.size > 0
                    error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Source Path.", :parameters => details}).to_json()]
                end
                unless details[:destination].to_s.size > 0
                    error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Destination Path.", :parameters => details}).to_json()]
                end
                if error_response
                    response = error_response
                else
                    source_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:source].to_s).gsub("//","/")
                    destination_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:destination].to_s).gsub("//","/")
                    result = GxG::SERVICES[:core][:resources].copy(source_path, @credential, destination_path)
                    if result[:result] == true
                        response = [200, {"content-type" => "application/json"}, result.to_json()]
                    else
                        response = [403, {"content-type" => "application/json"}, result.to_json()]
                    end
                end
            end
            response
        end
        #
        def vfs_move(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                error_response = nil
                unless details[:source].to_s.size > 0
                    error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Source Path.", :parameters => details}).to_json()]
                end
                unless details[:destination].to_s.size > 0
                    error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Destination Path.", :parameters => details}).to_json()]
                end
                if error_response
                    response = error_response
                else
                    source_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:source].to_s).gsub("//","/")
                    destination_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:destination].to_s).gsub("//","/")
                    result = GxG::SERVICES[:core][:resources].copy(source_path, @credential, destination_path)
                    if result[:result] == true
                        response = [200, {"content-type" => "application/json"}, result.to_json()]
                    else
                        response = [403, {"content-type" => "application/json"}, result.to_json()]
                    end
                end
            end
            response
        end
        #
        def set_permissions(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                # Review : at this point, since home_path is by credential class - open to anyone to alter permissions in their respective areas.
                error_response = nil
                unless details[:revocations].is_a?(::Array)
                    error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Source Path.", :parameters => details}).to_json()]
                end
                unless details[:alterations].is_a?(::Array)
                    error_response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Destination Path.", :parameters => details}).to_json()]
                end
                if error_response
                    response = error_response
                else
                    the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s).gsub("//","/")
                    if GxG::SERVICES[:core][:resources].exist?(the_path)
                        (details[:revocations] || []).each do |the_credential|
                            # credentials whos permissions are to be revoked.
                            GxG::SERVICES[:core][:resources].revoke_permissions(the_path, the_credential.to_s.to_sym)
                        end
                        (details[:alterations] || []).each do |the_record|
                            GxG::SERVICES[:core][:resources].set_permissions(the_path, the_record[:credential], the_record[:permissions])
                        end
                        response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                    else
                        response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => details}).to_json()]
                    end
                end
            end
            response
        end
        #
        def get_format(details={})
            importation_record = {:formats => {}, :records => []}
            if details.is_a?(::Array)
                format_list = []
                details.each do |the_criteria|
                    if ::GxG::valid_uuid?(the_criteria)
                        ::GxG::DB[:roles][:formats].format_list({:uuid => the_criteria.to_s.to_sym}).each do |the_format|
                            format_list << the_format
                        end
                    else
                        ::GxG::DB[:roles][:formats].format_list({:ufs => the_criteria.to_s}).each do |the_format|
                            format_list << the_format
                        end
                    end
                end
            else
                format_list = ::GxG::DB[:roles][:formats].format_list(details)
            end
            format_list.each do |the_format_header|
                format_record = ::GxG::DB[:roles][:formats].format_load({:uuid => the_format_header[:uuid]})
                format_record[:content] = format_record[:content].gxg_export
                importation_record[:formats][(the_format_header[:uuid])] = format_record
            end
            [200, {"content-type" => "application/json"}, {:result => importation_record}.to_json()]
        end
        #
        def put_format(details={})
            if GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:administrators], @credential) || GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:developers], @credential)
                result = ::GxG::DB[:roles][:formats].sync_import(GxG::DB[:administrator],details)
                [200, {"content-type" => "application/json"}, {:result => result}.to_json()]
            else
                [403, {"content-type" => "application/json"}, ({:result => false, :error => "You do not have sufficient permissions to do this.", :parameters => details}).to_json()]
            end
        end
        #
        def get_object(details={})
            if details[:path].to_s.size > 0
                if details[:path].to_s.include?("/Public/www")
                    [200, {"content-type" => "application/json"}, {:result => (((GxGwww::CACHE.fetch(details[:path].to_s, @credential, true)) || {})[:data] || "")}.to_json()]
                else
                    if details[:path].to_s[0..4] == "/User"
                        the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s[5..-1]).gsub("//","/")
                        [200, {"content-type" => "application/json"}, {:result => (((GxGwww::CACHE.fetch(the_path, @credential, false)) || {})[:data] || "")}.to_json()]
                    else
                        if details[:path].to_s[0..6] == "/Shared"
                            # Review : Expansion --> work out a scheme for shared group folders/files/db-obj (WebDAV mounts??)
                            # [403, {"content-type" => "application/json"}, ({:result => false, :error => "Not Yet Implemented.", :parameters => details}).to_json()]
                            the_path = ("/Users/Shared/" + details[:path].to_s[7..-1]).gsub("//","/")
                            [200, {"content-type" => "application/json"}, {:result => (((GxGwww::CACHE.fetch(the_path, @credential, false)) || {})[:data] || "")}.to_json()]
                        else
                            [200, {"content-type" => "application/json"}, {:result => (((GxGwww::CACHE.fetch(details[:path].to_s, @credential, false)) || {})[:data] || "")}.to_json()]
                        end
                    end
                end
            else
                if GxG::valid_uuid?(details[:uuid].to_s)
                    [200, {"content-type" => "application/json"}, {:result => (((GxGwww::CACHE.fetch_by_uuid(details[:uuid].to_s.to_sym, @credential, false)) || {})[:data] || "")}.to_json()]
                else
                    [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Specifier.", :parameters => details}).to_json()]
                end
            end
        end
        #
        def put_object(details={})
            response = nil
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details[:object].is_a?(::Hash)
                    database = nil
                    the_object = ::GxG::DB[:roles][:data].retrieve_by_uuid(details[:uuid].to_s.to_sym, ::GxG::DB[:administrator])
                    if the_object
                        database = the_object.db_address()[:database]
                        the_object.deactivate
                        if details[:path].to_s.size > 0
                            handle = ::GxG::SERVICES[:core][:resources].open(details[:path].to_s, ::GxG::DB[:administrator])
                            if handle.is_a?(::Hash)
                                database = handle[:resource].db_address()[:database]
                                ::GxG::SERVICES[:core][:resources].close(handle[:token])
                            else
                                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Error finding object database.", :parameters => false}).to_json()]
                            end
                        end
                    else
                        # needs to be created
                        if details[:path].to_s.size > 0
                            status = ::GxG::SERVICES[:core][:resources].create(details[:path].to_s, @credential, {:with_uuid => details[:uuid].to_s.to_sym})
                            unless status[:result] == true
                                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => status[:error], :parameters => false}).to_json()]
                            end
                            unless response
                                handle = ::GxG::SERVICES[:core][:resources].open(details[:path].to_s, ::GxG::DB[:administrator])
                                if handle.is_a?(::Hash)
                                    database = handle[:resource].db_address()[:database]
                                    ::GxG::SERVICES[:core][:resources].close(handle[:token])
                                else
                                    response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Error finding object database.", :parameters => false}).to_json()]
                                end
                            end
                        else
                            database = ::GxG::DB[:roles][:data]
                        end
                    end
                    if database.is_a?(::GxG::Database::Database)
                        status = database.sync_import(@credential, details[:object])
                        if status == true
                            response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                            GxGwww::CACHE.flush_cache_item(details[:uuid].to_s)
                            if details[:path].to_s.size > 0
                                GxGwww::CACHE.flush_cache_item(details[:path].to_s)
                            end
                        else
                            response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Error writing data.", :parameters => false}).to_json()]
                        end
                    else
                        response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Unable to find a suitable database.", :parameters => false}).to_json()]
                    end
                else
                    if details[:object].is_a?(::String)
                        if details[:path].to_s.size > 0
                            unless ::GxG::SERVICES[:core][:resources].exist?(details[:path].to_s)
                                status = ::GxG::SERVICES[:core][:resources].create(details[:path].to_s, @credential)
                                unless status[:result] == true
                                    response = [500, {"content-type" => "application/json"}, ({:result => false, :error => status[:error], :parameters => false}).to_json()]
                                end
                            end
                            unless response
                                handle = ::GxG::SERVICES[:core][:resources].open_writable(details[:path].to_s, @credential)
                                if handle.is_a?(::Hash)
                                    handle[:resource].rewind
                                    handle[:resource].write(details[:object].decode64)
                                    ::GxG::SERVICES[:core][:resources].close(handle[:token])
                                    response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                                else
                                    response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Unable to open file.", :parameters => false}).to_json()]
                                end
                            end
                        else
                            response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "You MUST specify a valid path.", :parameters => false}).to_json()]
                        end
                    else
                        response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Object Type.", :parameters => false}).to_json()]
                    end
                end
            end
            response
        end
        #
        def get_permissions(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details[:path].to_s.size > 0
                    the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s).gsub("//","/")
                    result = []
                    if GxG::SERVICES[:core][:resources].exist?(the_path)
                        result = GxG::SERVICES[:core][:resources].get_permissions(the_path, @credential)
                    end
                    response = [200, {"content-type" => "application/json"}, {:result => result.to_json.encode64}.to_json()]
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Path.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def search_database(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                search_result = {}
                if details[:criteria].is_a?(::Hash)
                    details[:criteria].keys.each do |the_role|
                        if ::GxG::DB[:roles].keys.include?(the_role)
                            # Fix for string/symbol hoo-hah:
                            if details[:criteria][(the_role)][:select].is_a?(::Array)
                                new_selector = []
                                details[:criteria][(the_role)][:select].each do |the_selector|
                                    new_selector << the_selector.to_s.to_sym
                                end
                                details[:criteria][(the_role)][:select] = new_selector
                            end
                            search_result[(the_role)] =  ::GxG::DB[:roles][(the_role)].search_database(@credential, details[:criteria][(the_role)])
                        end
                    end
                    response = [200, {"content-type" => "application/json"}, {:result => search_result.to_json.encode64}.to_json()]
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Criteria.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def search_pull(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                importation_record = {:formats => {}, :records => []}
                pull_list = []
                if details[:criteria].is_a?(::Hash)
                    details[:criteria].keys.each do |the_role|
                        if ::GxG::DB[:roles].keys.include?(the_role)
                            # Fix for string/symbol hoo-hah:
                            if details[:criteria][(the_role)][:select].is_a?(::Array)
                                new_selector = []
                                details[:criteria][(the_role)][:select].each do |the_selector|
                                    new_selector << the_selector.to_s.to_sym
                                end
                                details[:criteria][(the_role)][:select] = new_selector
                            end
                            (::GxG::DB[:roles][(the_role)].search_database(@credential, details[:criteria][(the_role)]).map {|entry| entry[:uuid]}).each do |the_uuid|
                                unless pull_list.include?(the_uuid)
                                    pull_list << the_uuid
                                end
                            end                            
                        end
                    end
                    #
                    pull_list.each do |the_uuid|
                        the_record = ::GxG::DB[:roles][:data].retrieve_by_uuid(the_uuid, @credential)
                        if the_record.is_a?(::GxG::Database::PersistedHash)
                            the_record.search do |value, selector, container|
                                format_uuid = nil
                                if value.is_a?(::GxG::Database::PersistedHash)
                                    if value.format
                                        format_uuid = value.format
                                    end
                                end
                                if value.is_a?(::GxG::Database::PersistedArray)
                                    if value.constraint
                                        format_uuid = value.constraint
                                    end
                                end
                                if format_uuid
                                    unless importation_record[:formats].keys.include?(format_uuid)
                                        format_record = ::GxG::DB[:roles][:formats].format_load({:uuid => format_uuid})
                                        if format_record
                                            format_record[:content] = format_record[:content].gxg_export
                                            importation_record[:formats][(format_uuid)] = format_record
                                        end
                                    end
                                end
                            end
                            importation_record[:records] << the_record.export
                        end
                    end
                    #
                    response = [200, {"content-type" => "application/json"}, {:result => importation_record}.to_json()]
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Criteria.", :parameters => details}).to_json()]
                end
            end
            response
        end
        #
        def entries(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                if details[:path].to_s.size > 0
                    the_path = (GxG::SERVICES[:core][:resources].home_path(@credential).to_s + "/" + details[:path].to_s).gsub("//","/")
                    if GxG::SERVICES[:core][:resources].exist?(the_path)
                        response = [200, {"content-type" => "application/json"}, {:result => GxG::SERVICES[:core][:resources].entries(the_path, @credential).to_json.encode64}.to_json()]
                    else
                        response = [404, {"content-type" => "application/json"}, ({:result => false, :error => "Not Found.", :parameters => details}).to_json()]
                    end
                else
                    response = [403, {"content-type" => "application/json"}, ({:result => false, :error => "Invalid Path.", :parameters => details}).to_json()]
                end                
            end
            response
        end
        #
        def destroy_object(details={})
            # details[:uuid] : specifies uuid of db object to destroy.
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                success = false
                GxG::DB[:roles].keys.each do |the_role|
                    the_permissions = GxG::DB[:roles][(the_role)].effective_uuid_permission(details[:uuid].to_s.to_sym, @credential)
                    if the_permissions.is_a?(::Hash)
                        if the_permissions[:destroy] == true
                           if GxG::DB[:roles][(the_role)].destroy_by_uuid(@credential, details[:uuid].to_s.to_sym) == true
                            unless success == true
                                success = true
                            end
                           end
                        end
                    end
                end
                response = [200, {"content-type" => "application/json"}, {:result => success}.to_json()]
            end
            response
        end
        #
        def get_library(details={})
            # Supply: details => {:library => "lib-name", :manifest => true/false, :dependencies => true/false, :minimum => 0.0, :maximum => 0.0, :loaded => [<UUID>...]}
            # Grab library by name and version params. optionally deliver full stack of in-order load deps.
            minimum = details[:minimum] || 0.0
            maximum = details[:maximum]
            marshalled = []
            if details[:loaded].is_a?(::Array)
                details[:loaded].each do |the_uuid|
                    marshalled << the_uuid.to_s.to_sym
                end
            end
            the_lib = nil
            the_list = []
            manifest = GxG::DB[:roles][:software].uuid_list(@credential, {:select => [:uuid, :version], :title => (details[:library]), :order => {:descending => :version}})
            manifest.each do |the_record|
                if maximum
                    if ((minimum)..(maximum)).include?(the_record[:version])
                        the_lib = the_record
                        break
                    end
                else
                    if the_record[:version] >= minimum
                        the_lib = the_record
                        break
                    end
                end
            end
            if the_lib
                if details[:dependencies] == true
                    # calculate dependencies (in proper load order)
                    dep_template = {:library => "", :uuid => nil, :version => 0.0, :minimum => 0.0, :maximum => nil, :dependencies => []}
                    deps = {}
                    the_base_lib = GxG::DB[:roles][:software].retrieve_by_uuid(the_lib[:uuid].to_s.to_sym,@credential)
                    build_queue = [(the_base_lib)]
                    while build_queue.size > 0 do
                        entry = build_queue.shift
                        if entry
                            unless deps[(entry.uuid)]
                                new_dep = dep_template.clone
                                new_dep[:library] = entry.title
                                new_dep[:uuid] = entry.uuid
                                new_dep[:version] = entry.version
                                deps[(entry.uuid)] = new_dep
                            end
                            #
                            if entry[:requirements].is_a?(::GxG::Database::PersistedArray)
                                entry[:requirements].each do |the_dep|
                                    # libarary requirement format: {:library => "", :type => "", :minimum => 0.0, :maximum => nil}
                                    new_dep = nil
                                    #
                                    new_list = GxG::DB[:roles][:software].uuid_list(@credential, {:select => [:uuid, :version], :title => (the_dep[:library].to_s), :order => {:descending => :version}})
                                    new_list.each do |the_item|
                                        if the_dep[:maximum]
                                            if ((the_dep[:minimum])..(the_dep[:maximum])).include?(the_item[:version])
                                                new_dep = dep_template.clone
                                                new_dep[:library] = the_dep[:library].to_s
                                                new_dep[:uuid] = the_item[:uuid]
                                                new_dep[:version] = the_item[:version]
                                                new_dep[:minimum] = the_dep[:minimum].to_f
                                                new_dep[:maximum] = the_dep[:maximum].to_f
                                                break
                                            end
                                        else
                                            if the_item[:version] >= the_dep[:minimum]
                                                new_dep = dep_template.clone
                                                new_dep[:library] = the_dep[:library].to_s
                                                new_dep[:uuid] = the_item[:uuid]
                                                new_dep[:version] = the_item[:version]
                                                new_dep[:minimum] = the_dep[:minimum].to_f
                                                break
                                            end
                                        end
                                    end
                                    #
                                    if new_dep
                                        deps[(entry.uuid)][:dependencies] << new_dep
                                        build_queue << (GxG::DB[:roles][:software].retrieve_by_uuid(new_dep[:uuid].to_s.to_sym,@credential))
                                    end
                                end
                            end
                            #
                            entry.deactivate
                        end
                    end
                    deps_pool = (deps.sort_by {|key,value| value[:dependencies].size}).to_h
                    deps_pool.each_pair do |the_uuid,the_record|
                        the_record[:dependencies].each do |the_dep|
                            unless marshalled.include?(the_dep[:uuid])
                                if details[:manifest] == true
                                    the_list << {:library => the_record[:library], :uuid => the_dep[:uuid], :version => the_record[:version]}
                                else
                                    data = GxGwww::CACHE.fetch(the_dep[:uuid].to_s,@credential)
                                    the_list << {:library => the_record[:library], :uuid => the_dep[:uuid], :version => the_record[:version], :data => data[:data]}
                                end
                                marshalled << the_uuid
                            end
                        end
                        unless marshalled.include?(the_uuid)
                            if details[:manifest] == true
                                the_list << {:library => the_record[:library], :uuid => the_uuid, :version => the_record[:version]}
                            else
                                data = GxGwww::CACHE.fetch(the_uuid.to_s,@credential)
                                the_list << {:library => the_record[:library], :uuid => the_uuid, :version => the_record[:version], :data => data[:data]}
                            end
                            marshalled << the_uuid
                        end
                    end
                else
                    # pull and append library object record to content[:data]
                    data = GxGwww::CACHE.fetch(the_lib[:uuid].to_s,@credential)
                    the_list << {:library => details[:library], :version => the_lib[:version], :data => data}
                end
            end
            #
            [200, {"content-type" => "application/json"}, {:result => the_list.to_json.encode64}.to_json()]
        end
        #
        def application_menu()
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                results = []
                app_menu = (GxGwww::Applications::MENU || [])
                # entry: {:location => "", :application_icon => "", :application_name => "", :credentialed => false, :unique => true :category => ""}
                # ...
                app_menu.each do |entry|
                    begin
                        profile = ::GxG::VFS.profile(("/Public/www" << entry[:location].to_s), {:with_credential => @credential, :follow_symlinks => true})
                        if profile.is_a?(::Hash)
                            if profile[:permissions][:effective][:read] == true
                                results << entry
                            end
                        end
                    rescue Exception => the_error
                        log_warn("Cannot access application: #{"/Public/www" << entry[:location].to_s}")
                    end
                end
                response = [200, {"content-type" => "application/json"}, {:result => results.to_json.encode64}.to_json()]
            end
            response
        end
        #
        def application_list()
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                results = []
                @application_states.each do |the_app|
                    results << {:application => the_app[:application].to_s, :credentialed => the_app[:credentialed], :unique => the_app[:unique], :location => the_app[:location].to_s}
                end
                response = [200, {"content-type" => "application/json"}, {:result => results.to_json.encode64}.to_json()]
            end
            response
        end
        #
        def application_close(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                found = nil
                @application_states.each_with_index do |the_app, the_index|
                    if the_app[:application] == details[:application]
                        found = the_index
                        break
                    end
                end
                if found
                    record = @application_states.delete_at(found)
                    response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                else
                    response = [200, {"content-type" => "application/json"}, {:result => false}.to_json()]
                end
            end
            response
        end
        #
        def application_open(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                credentialed = false
                unique = false
                unless details[:path]
                    app_menu = (GxGwww::Applications::MENU || [])
                    # entry: {:location => "", :application_icon => "", :application_name => "", :credentialed => false, :unique => true :category => ""}
                    # ...
                    app_menu.each do |the_entry|
                        if details[:name] == File.basename(the_entry[:location])
                            details[:path] = the_entry[:location]
                            break
                        end
                    end
                end
                begin
                    # Review : switch over to new resource accessor??
                    # GxG::SERVICES[:core][:resources].open(the_path, @credential)
                    # token format : {:token => the_token, :path => the_path, :resource => the_resource}
                    # the_object = GxG::VFS.open("/Public/www" << details[:path].to_s)
                    the_object_token = GxG::SERVICES[:core][:resources].open(("/Public/www" << details[:path].to_s), @credential)
                    if the_object_token
                        the_object = the_object_token[:resource]
                    else
                        the_object = nil
                    end
                rescue
                    the_object_token = nil
                    the_object = nil
                end
                if the_object.is_a?(::GxG::Database::PersistedHash)
                    # source_uuid = the_object.uuid
                    the_options = the_object[:options]
                    if the_options[:credentialed]
                        credentialed = the_options[:credentialed]
                    end
                    if the_options[:unique]
                        unique = the_options[:unique]
                    end
                    app_uuid = GxG::uuid_generate.to_s.to_sym
                    the_options = nil
                    the_object.deactivate
                    already_running = false
                    if unique || (details[:restore] == true)
                        @application_states.each do |the_app_record|
                            if the_app_record[:location] == details[:path].to_s
                                already_running = true
                                app_uuid = the_app_record[:application]
                                break
                            end
                        end
                    end
                    #
                    if already_running == true
                        if details[:restore] == true
                            response = [200, {"content-type" => "application/json"}, {:result => {:application => app_uuid.to_s, :location => details[:path].to_s}.to_json().encode64}.to_json()]
                        else
                            if unique
                                response = [403, {"content-type" => "application/json"}, {:result => false, :error => "Already Running"}.to_json()]
                            else
                                somedata = GxGwww::CACHE.fetch(details[:path].to_s,@credential)
                                if somedata
                                    app_uuid = GxG::uuid_generate.to_s.to_sym
                                    response = [200, {"content-type" => "application/json"}, {:result => {:application => app_uuid.to_s, :location => details[:path].to_s}.to_json().encode64}.to_json()]
                                    @application_states << {:application => app_uuid.to_s, :credentialed => credentialed, :unique => unique, :location => details[:path].to_s, :status => "exitready", :data => nil}
                                else
                                    response = [403, {"content-type" => "application/json"}, {:result => false, :error => "Could not locate application in storage  #{details.inspect}"}.to_json()]
                                end
                            end
                        end
                    else
                        somedata = GxGwww::CACHE.fetch(details[:path].to_s,@credential)
                        if somedata
                            response = [200, {"content-type" => "application/json"}, {:result => {:application => app_uuid.to_s, :location => details[:path].to_s}.to_json().encode64}.to_json()]
                            @application_states << {:application => app_uuid.to_s, :credentialed => credentialed, :unique => unique, :location => details[:path].to_s, :status => "exitready", :data => nil}
                        else
                            response = [403, {"content-type" => "application/json"}, {:result => false, :error => "Could not locate application in storage  #{details.inspect}"}.to_json()]
                        end
                    end
                    #
                else
                    response = [403, {"content-type" => "application/json"}, {:result => false, :error => "Invalid name or path:  #{details.inspect}"}.to_json()]
                end
                #
                if the_object_token
                    GxG::SERVICES[:core][:resources].close(the_object_token[:token])
                end
            end
            response
        end
        #
        def app_state_pull(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                record = nil
                @application_states.each_with_index do |the_app, the_index|
                    if the_app[:application] == details[:application]
                        record = @application_states[(the_index)]
                        break
                    end
                end
                if record
                    response = [200, {"content-type" => "application/json"}, {:result => record.to_json().encode64}.to_json()]
                else
                    response = [200, {"content-type" => "application/json"}, {:result => {}.to_json().encode64}.to_json()]
                end
            end
            response
        end
        #
        def app_state_push(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                found = nil
                @application_states.each_with_index do |the_app, the_index|
                    if the_app[:application] == details[:application]
                        found = index
                        break
                    end
                end
                # decode payload prior
                content = details[:data]
                if found
                    if content
                        # {:application => app_uuid.to_s, :credentialed => credentialed, :unique => unique, :location => details[:path].to_s, :status => "exitready", :data => nil}
                        @application_states[(found)][:data] = content
                        @application_states[(found)][:status] = "exitready"
                        response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                    else
                        # error
                        response = [500, {"content-type" => "application/json"}, {:result => false, :error => "State Data Missing.", :parameters => details[:data]}.to_json()]
                    end
                else
                    response = [404, {"content-type" => "application/json"}, {:result => false, :error => "Application Not Found.", :parameters => details[:application]}.to_json()]
                end
            end
            response
        end
        #
        def format_pull(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                # Uncredentialed applications might pull formats - no credential screening for now.
                records = []
                if details[:criteria].is_a?(::Hash)
                    criterias = [(details[:criteria])]
                else
                    criterias = details[:criteria]
                end
                if criterias.is_a?(::Array)
                    criterias.each do |the_criteria|
                        GxG::DB[:roles][:formats].format_list(the_criteria).each do |the_format_stub|
                            if the_format_stub[:ufs].to_s.size > 0
                                records << (GxG::DB[:roles][:formats].format_load({:ufs => the_format_stub[:ufs]}))
                            else
                                if the_format_stub[:uuid].to_s.size > 0
                                    records << (GxG::DB[:roles][:formats].format_load({:uuid => the_format_stub[:uuid].to_s.to_sym}))
                                end
                            end
                        end
                    end
                end
                response = [200, {"content-type" => "application/json"}, {:result => records.to_json.encode64}.to_json()]
            end
            response
        end
        #
        def format_push(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                begin
                    unless GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:administrators], @credential) || GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:developers], @credential)
                        raise Exception, "You do not have permissions sufficient to write this format."
                    end
                    # Check inputs
                    unless ::GxG::valid_uuid?(details[:uuid].to_s.to_sym)
                      raise Exception, "Invalid UUID passed for the format"
                    end
                    unless details[:type].is_any?(::String, ::Symbol)
                      raise Exception, "You must pass the format_record[:type] as a String or Symbol"
                    end
                    unless details[:ufs].is_any?(::String, ::Symbol)
                      raise Exception, "You must pass the format_record[:ufs] as a String or Symbol"
                    end
                    unless details[:title].is_a?(::String)
                      raise Exception, "You must pass the format_record[:title] as a String"
                    end
                    unless details[:version].is_a?(::Float)
                      raise Exception, "You must pass the format_record[:version] as a Float"
                    end
                    unless details[:mime_types].is_any?(::String, ::Array)
                      raise Exception, "You must pass the format_record[:mime_types] as a String"
                    end
                    unless details[:content].is_a?(::Hash)
                      raise Exception, "You must pass the format_record[:content] as a Hash"
                    end
                    unless GxG::DB[:roles][:formats].persistable?(details[:content])
                      raise Exception, "You must pass the format_record[:content] as a Hash of persistable elements"
                    end
                    # prepare format record
                    format_record = GxG::DB[:roles][:formats].format_template(details[:type].to_s.to_sym)
                    unless format_record
                        raise ArgumentError, "Invalid format structural type"
                    end
                    format_record[:uuid] = details[:uuid].to_s.to_sym
                    format_record[:type] = details[:type].to_s.to_sym
                    format_record[:ufs] = details[:ufs].to_s
                    format_record[:title] = details[:title].to_s
                    format_record[:version] = details[:version].to_f
                    format_record[:mime_types] = details[:mime_types]
                    format_record[:content] = details[:content]
                    # If format exists, update, else create
                    if GxG::DB[:roles][:formats].format_list({:uuid => details[:uuid].to_s.to_sym}).size > 0
                        unless GxG::DB[:roles][:formats].format_update(format_record)
                            raise Exception, "Unkown Format Update Error"
                        end
                    else
                        unless GxG::DB[:roles][:formats].format_create(format_record)
                            raise Exception, "Unkown Format Creation Error"
                        end
                    end
                    response = [200, {"content-type" => "application/json"}, {:result => true}.to_json()]
                rescue Exception => the_error
                    response = [500, {"content-type" => "application/json"}, ({:result => false, :error => the_error.to_s, :parameters => details}).to_json()]
                end
                #
            end
            response
        end
        #
        def format_template(details={})
            begin
                format_record = GxG::DB[:roles][:formats].format_template(details[:type].to_s.to_sym)
                unless format_record
                    raise ArgumentError, "Invalid format structural type"
                end
                response = [200, {"content-type" => "application/json"}, {:result => format_record.to_json.encode64}.to_json()]
            rescue Exception => the_error
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => the_error.to_s, :parameters => details}).to_json()]
            end
            response
        end
        #
        def format_list(details={})
            if self.closed?
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => "Connector Closed.", :parameters => false}).to_json()]
            else
                response = [200, {"content-type" => "application/json"}, {:result => GxG::DB[:roles][:formats].format_list(details).to_json.encode64}.to_json()]
            end
            response
        end
        #
        def format_destroy(details={})
            begin
                unless GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:administrators], @credential) || GxG::DB[:authority].role_member?(GxG::DB[:authority][:system_credentials][:developers], @credential)
                    raise Exception, "You do not have permissions sufficient to destroy this format."
                end
                criteria={}
                if GxG::valid_uuid?(details[:uuid])
                    criteria[:uuid] = details[:uuid].to_s.to_sym
                else
                    if details[:ufs].is_a?(::String)
                        criteria[:ufs] = details[:ufs].to_s
                    end
                end
                unless criteria.keys.size > 0
                    raise ArgumentError, "You must specify which format to destroy with either :uuid or :ufs specifier."
                end                
                response = [200, {"content-type" => "application/json"}, {:result => GxG::DB[:roles][:formats].format_destroy(criteria)}.to_json()]
            rescue Exception => the_error
                response = [500, {"content-type" => "application/json"}, ({:result => false, :error => the_error.to_s, :parameters => details}).to_json()]
            end
            response
        end
        # ---------------------------------------------
    end
    #
end
#
module GxGwww
    # ---------------------------------------------------------------------
    CACHE = ::GxGwww::Storage::UnifiedMemoryCache.new
    # ---------------------------------------------------------------------
end
#
